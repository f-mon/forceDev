// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';

import 'package:forceDev/model/user.dart';
import 'package:forceDev/newt.dart';
import 'package:paper_elements/paper_action_dialog.dart';
import 'package:paper_elements/paper_button.dart';
import 'package:core_elements/core_drawer_panel.dart';
import 'package:polymer/polymer.dart';

@CustomTag('app-container')
class AppContainer extends PolymerElement {
  
  @observable String reversed = '';
  @observable List<MenuItem> menu = toObservable([]);
  @observable bool drawerNarrow=false;
  @observable ActivityManager activityManager;
  
  @observable NewtUser user; 
  
  AppContainer.created() : super.created();

  ready() {
    super.ready();
    activityManager = new ActivityManager();
    activityManager.startedActivitiesStream.listen(onActivityStarted);
    
    ActivityDef defaultLoginApp = new ActivityDef("LoginActivity", "Login", "login-app", false);
    ActivityDef userInfoApp = new ActivityDef("UserInfoActivity", "Profile", "user-info-app");
    activityManager.activityRegistry
      ..registerActivityDef(defaultLoginApp)
      ..registerActivityDef(userInfoApp);
     
    activityManager.startChildPopupActivity(defaultLoginApp.name).then((a){
      a.whenClose((u){
        if (u!=null) {
          this.user = u;
          activityManager.activityRegistry.registerActivities(this);
          _createMenu();
        }
      });
    });
  }

  void _createMenu() {
    Element menuNode = this.querySelector("[data-specs='menu']");
    menuNode.children.forEach((n){
      String activityName = n.attributes['activity'];
      menu.add(new ActivityMenuItem(activityManager.getActivityDef(activityName)));
    });
  }
  
  void toggleMenu(Event event, var detail, var target) {  
    CoreDrawerPanel cdp = $['drawerPanel'] as CoreDrawerPanel;
    if (!drawerNarrow && cdp.narrow) {
      cdp.togglePanel();
    } else {
      drawerNarrow = !drawerNarrow;
    }
  }
  
  void startMenu(Event event, var detail, var target) { 
    String index = target.attributes['data-index'];
    MenuItem menuItem = menu[int.parse(index)];    
    startMenu_(menuItem);
  }
  
  void startMenu_(MenuItem menuItem) {
    menuItem.start(this);
  }

  void startActivity(ActivityDef activityDef) {
    activityManager.startRootActivity(activityDef.name);
  }
  
  void onActivityStarted(Activity a) {
    ActivityHostElement activityHostElement;
    if (a.activityMode==ActivityMode.POPUP) {
      activityHostElement = new ActivityPopupHostElement($['appContent'],activityManager);
    }
    else if (a.isRoot()){
      activityHostElement = new ActivityDivHostElement($['appContent']);
    } else {
      activityHostElement = a.parent.activityHostElement;
    }
    a.showInto(activityHostElement);
  }
  
  void closeActivity() { 
    activityManager.closeActivity();
  }
  
  void showUserProfile() {
    if (!isLogged()) 
      return;
    activityManager.startChildPopupActivity("UserInfoActivity",{
      'user': this.user
    });
  }
  
  bool isLogged() => this.user!=null;
  
}

class MenuItem extends Observable {
    
  @observable String label;
  
  MenuItem(this.label);
  
  void start(AppContainer mainApp) {}
  
}

class ActivityMenuItem extends MenuItem {
  
  ActivityDef activityDef;
  
  ActivityMenuItem(ActivityDef activityDef) : super(activityDef.label) {
    this.activityDef = activityDef;
  }
  
  @override
  void start(AppContainer mainApp) {
    mainApp.startActivity(activityDef);
  }
  
}


class ActivityPopupHostElement implements ActivityHostElement {
  
  PaperActionDialog dialog;
  PaperButton closeButton;
  
  List<Activity> activityStack = [];
  
  ActivityPopupHostElement(HtmlElement parentElement,ActivityManager activityManager) {
    dialog = new Element.tag("paper-action-dialog");
    dialog.setAttribute('transition','core-transition-center');
    dialog.setAttribute('backdrop','');
    dialog.setAttribute('autoCloseDisabled','');
    dialog.setAttribute('layered','false');
    dialog.setAttribute('closeSelector','');
    closeButton = new Element.tag("paper-button");
    closeButton.setAttribute('affirmative','');
    closeButton.onClick.listen((e){
        activityManager.closeActivity();
    });
    closeButton.text = 'Close';
    dialog.append(closeButton);
    parentElement.append(dialog);
  }
  
  @override
  void display(Activity activity) {
    if (activityStack.isNotEmpty) {
      activityStack.last.view.style.display = "none";
      dialog.append(activity.view);
    } else {
      dialog.append(activity.view);
      dialog.open(); 
    }
    activityStack.add(activity);
    closeButton.hidden = !activity.activitydef.closable;
  }
  
  @override
  void remove(Activity activity) {
    activityStack.remove(activity);
    if (activityStack.isEmpty) {      
      dialog.close();
    } else {      
      activity.view.remove();
      activityStack.last.view.style.display = "block";
    }
  }
}

class ActivityDivHostElement implements ActivityHostElement {
  
  HtmlElement element;
  
  List<Activity> activityStack = [];
  
  ActivityDivHostElement(HtmlElement this.element);

  @override
  void display(Activity activity) {
    if (activityStack.isNotEmpty) {
      activityStack.last.view.style.display = "none";
    }
    activityStack.add(activity);
    this.element.append(activity.view);        
  }

  @override
  void remove(Activity activity) {
    activity.view.remove();
    activityStack.remove(activity);
    if (activityStack.isNotEmpty) {
      activityStack.last.view.style.display = "block";
    }
  }
}


