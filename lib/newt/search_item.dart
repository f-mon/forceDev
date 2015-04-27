
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:forceDev/newt/search_result.dart';
import 'package:template_binding/template_binding.dart';

@CustomTag('search-item')
class SearchItem extends PolymerElement {
  
  SearchItem.created() : super.created();

  @observable
  SearchResult searchResult;
  
  @published dynamic model;
  
  @published bool selected;

  @observable bool rowTemplateInjected=false;

  @observable List<ItemAction> itemActions = toObservable([]);


  @override 
  ready() {
    super.ready();

    this.onClick.listen(onDataItemClick);
    this.on['item-selected'].listen(onItemSelected);
    this.on['item-deselected'].listen(onItemDeselected);
    onPropertyChange(this,#model,onModelChange);
  }

  @override
  domReady() {

  }

  void onModelChange() {
    selected = searchResult.isSelected(model);
    itemActions.clear();
    itemActions.addAll(searchResult.getItemActionsForModel(model));
  }
  
  @override
  attached() {
    fire('item-attached',detail: this);
    TemplateElement tmp = this.searchResult.rowTemplate;
    TemplateBindExtension ex = templateBind(tmp);
    this.shadowRoot.querySelector("#content").replaceWith(ex.createInstance(this,this.bindings));
    this.rowTemplateInjected = true;
  }
  
  @override
  detached() {
    fire('item-detached',detail: this);
  }

  void onItemActionClick(MouseEvent e, detail, target) {
    e.stopPropagation();
    String actionName = target.attributes["data-name"];
    ItemAction itemAction = itemActions.firstWhere((a)=>a.name==actionName);
    fire("item-action",detail:{
      'itemAction': itemAction,
      'searchItem': this,
      'model': this.model
    });
  }

  void onDataItemClick(MouseEvent e) {
    if (selected)
      fire('item-deselect',detail: model);
    else
      fire('item-select',detail: model);
  }
  
  void onItemSelected(CustomEvent e) {
    if (e.detail==this.model) {
      this.selected = true;
    }
  }
  
  void onItemDeselected(CustomEvent e) {
    if (e.detail==this.model) {
      this.selected = false;
    }  
  }
  
}