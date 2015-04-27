import 'package:forceDev/newt.dart';
import 'package:polymer/polymer.dart';
import 'package:forceDev/newt/search_result.dart';
import 'dart:html';
import 'dart:async';

@CustomTag('list-app')
class ListApp extends ActivityComponent {

  ListApp.created() : super.created();

  @observable Map searchInput = {};

  @observable List data;
  @observable bool loading = false;

  @override
  ready() {
    super.ready();
    data = toObservable([]);
    this.on['activity-resumed'].listen((p){search();});
  }

  Future<SearchResult> search() {
    this.loading = true;
    return performSearch(new SearchInput(searchInput))
    .then((result) {
      this.data.clear();
      this.data.addAll(result.data);
      this.loading = false;
      return result;
    });
  }

  Future<SearchResult> performSearch(SearchInput input) {
    return new Future.delayed(new Duration(milliseconds:50), () {
      List data2 = [];
      for (var i = 0; i < 10; i++) {
        var m = {
          'name':'Bob_${i}',
          'familiyName': '',
          'email': '',
          'birthDate': new DateTime.now()
        };
        data2.add(toObservable(m));
      }
      return new SearchResult(input, data2);
    });
  }

  void onItemAction(CustomEvent event) {
    ItemAction itemAction = event.detail['itemAction'];
    dynamic model = event.detail['model'];
    performItemAction(itemAction, model);
  }

  void onSearchAction(CustomEvent event) {
    SearchAction searchAction = event.detail['searchAction'];
    List models = event.detail['models'];
    performSearchAction(searchAction, models);
  }

  void performItemAction(ItemAction itemAction, model) {
    if (itemAction.name == 'open') {
      this.activity.activityManager.startChildActivity('editApp', {
        'mode': 'edit',
        'model': model
      });
    }
  }

  void performSearchAction(SearchAction searchAction, List selectedModels) {
    if (searchAction.name == 'new') {
      this.activity.activityManager.startChildActivity('editApp', {
        'mode': 'new',
        'model': createModelForNew()
      }).then((a) {
        a.whenClose((a) {
          print("a closed");
        });
      });
    }
  }

  dynamic createModelForNew() {
    return {};
  }

}

class SearchInput {

  Map filters;

  SearchInput(this.filters);

}

class SearchResult {

  SearchInput input;
  List data;

  SearchResult(this.input, this.data);

}
