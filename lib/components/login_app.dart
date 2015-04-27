
import 'package:forceDev/model/user.dart';
import 'package:forceDev/newt.dart';
import 'package:polymer/polymer.dart';

@CustomTag('login-app')
class LoginApp extends ActivityComponent {
  
  @observable String inputName;
  @observable String inputPassword;
  
  LoginApp.created() : super.created();

  ready() {
    super.ready();
  }
  
  login() {
    if (inputName!=null && inputName.isNotEmpty) {      
      activity.closeWithValue(new NewtUser(inputName));
    }
  }
  
}
