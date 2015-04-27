import 'package:forceDev/newt.dart';
import 'package:polymer/polymer.dart';
import 'package:forceDev/newt/search_result.dart';
import 'dart:html';
import 'dart:async';

@CustomTag('edit-app')
class EditApp extends ActivityComponent {

  EditApp.created() : super.created();

  @observable
  dynamic model;

  @override
  ready() {
    super.ready();
  }

}