import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:forceDev/newt/search_item.dart';

@CustomTag('search-result')
class SearchResult extends PolymerElement {
  
  SearchResult.created() : super.created();
  
  @published List data;
  @published bool loading;
  @published List selections;

  @observable List itemActions;
  @observable List searchActions;

  TemplateElement rowTemplate;

  @override
  void parseDeclaration(Element element) {
    rowTemplate = this.querySelector('#rowTemplate');
    super.parseDeclaration(element);
  }

  @override
  ready() {
    super.ready();
    _createItemActions();
    _createSearchActions();

    selections = toObservable([]);
    this.on["item-attached"].listen(onItemReady);
    this.on["item-detached"].listen(onItemDetached);
    this.on["item-select"].listen(onItemSelect);
    this.on["item-deselect"].listen(onItemDeselect);
  }

  void onSearchActionClick(MouseEvent e, detail, target) {
    e.stopPropagation();
    String actionName = target.attributes["data-name"];
    SearchAction searchAction = searchActions.firstWhere((a)=>a.name==actionName);
    fire("search-action",detail:{
      'searchAction': searchAction,
      'models': selections
    });
  }

  void _createItemActions() {
    this.itemActions = toObservable([]);
    this.itemActions.addAll(_readDeclaredItemActions());
    this.itemActions.addAll(_defaultItemActions());
  }
  void _createSearchActions() {
    this.searchActions = toObservable([]);
    this.searchActions.addAll(_readDeclaredSearchActions());
    this.searchActions.addAll(_defaultSearchActions());
  }

  List<ItemAction> _readDeclaredItemActions() {
    List<ItemAction> list = [];
    Element itemActionsNode = this.querySelector("[data-specs='item-actions']");
    itemActionsNode.children.forEach((n){
      String name = n.attributes['name'];
      String label = n.attributes['label'];
      String icon = n.attributes['actionIcon'];
      list.add(new ItemAction(name,label,icon));
    });
    return list;
  }

  List<ItemAction> _defaultItemActions() {
    List<ItemAction> list = [];
    list.add(new ItemAction("open","Open Record","chevron-right"));
    return list;
  }

  List<SearchAction> _readDeclaredSearchActions() {
    List<SearchAction> list = [];
    Element itemActionsNode = this.querySelector("[data-specs='search-actions']");
    itemActionsNode.children.forEach((n){
      String name = n.attributes['name'];
      String label = n.attributes['label'];
      String icon = n.attributes['actionIcon'];
      list.add(new SearchAction(name,label,icon));
    });
    return list;
  }

  List<SearchAction> _defaultSearchActions() {
    List<SearchAction> list = [];
    list.add(new SearchAction("new","New","add"));
    return list;
  }

  void onItemSelect(CustomEvent e) {
    if (!selections.contains(e.detail)) {
      selections.add(e.detail);
      shadowRoot.querySelectorAll("search-item").forEach((el)=>el.fire('item-selected',detail: e.detail));
      this.fire('item-selected',detail: e.detail);     
    }
  }
  
  void onItemDeselect(CustomEvent e) {
    if (selections.contains(e.detail)) {
      selections.remove(e.detail);
      shadowRoot.querySelectorAll("search-item").forEach((el)=>el.fire('item-deselected',detail: e.detail));
      this.fire('item-deselected',detail: e.detail);   
    }
  }

  void onItemReady(CustomEvent e) {
    (e.detail as SearchItem).searchResult = this;
  }

  void onItemDetached(CustomEvent e) {
    (e.detail as SearchItem).searchResult = null;
  }

  bool isSelected(dynamic model) {
    return selections.contains(model);
  }

  List<ItemAction> getItemActionsForModel(dynamic model) {
    return this.itemActions;
  }
}

class ItemAction extends Action {

  ItemAction(String name, String label, String icon) : super(name, label, icon);

}

class SearchAction extends Action {

  SearchAction(String name, String label, String icon) : super(name, label, icon);

}

class Action {

  String name;
  String label;
  String icon;

  Action(this.name,this.label,this.icon);

}