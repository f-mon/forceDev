
import 'package:forceDev/newt.dart';
import 'package:polymer/polymer.dart';

@CustomTag('form-editor')
class FormEditor extends ActivityComponent {
  
  FormEditor.created() : super.created();

  ready() {
    super.ready();
  }
  
  lauchForm() {
    this.activity.activityManager.startChildActivity("dynaForm",{ 'pippo':12345});
  }
  
}