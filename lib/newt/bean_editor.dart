import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:forceDev/newt/search_result.dart';
import 'package:template_binding/template_binding.dart';

@CustomTag('bean-editor')
class BeanEditor extends PolymerElement {

  BeanEditor.created() : super.created();

  @published dynamic model;

  @observable List<EditAction> editActions = toObservable([]);

  @override
  ready() {
    super.ready();
    editActions.clear();
    editActions.addAll(getEditActions());
    onPropertyChange(this,#model,onModelChange);
  }

  @override
  domReady() {

  }

  void onModelChange() {

  }

  @override
  attached() {

  }

  @override
  detached() {
  }

  void onEditActionClick(MouseEvent e, detail, target) {
    e.stopPropagation();
    String actionName = target.attributes["data-name"];
    EditAction editAction = editActions.firstWhere((a)=>a.name==actionName);
    fire("editActions-action",detail:{
      'editActions': editActions,
      'model': this.model
    });
  }

  List<EditAction> getEditActions() {
    List<EditAction> list = [];
    list.addAll(_readDeclaredEditActions());
    list.addAll(_defaultEditActions());
    return list;
  }

  List<EditAction> _readDeclaredEditActions() {
    List<EditAction> list = [];
    Element editActionsNode = this.querySelector("[data-specs='edit-actions']");
    if (editActionsNode!=null) {
      editActionsNode.children.forEach((n) {
        String name = n.attributes['name'];
        String label = n.attributes['label'];
        String icon = n.attributes['actionIcon'];
        list.add(new EditAction(name, label, icon));
      });
    }
    return list;
  }

  List<EditAction> _defaultEditActions() {
    List<EditAction> list = [];
    list.add(new EditAction("save","Salva","done"));
    list.add(new EditAction("delete","Elimina","delete"));
    list.add(new EditAction("cancel","Cancella","cached"));
    return list;
  }


}
class EditAction extends Action {

  EditAction(String name, String label, String icon) : super(name, label, icon);

}