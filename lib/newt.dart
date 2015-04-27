library newt;

import 'dart:html';
import 'dart:async';
import 'package:polymer/polymer.dart';

class ActivityManager extends Observable {
  
  @observable List<Activity> activityStack = toObservable([]);
  ActivityRegistry activityRegistry = new ActivityRegistry();
  
  StreamController<Activity> startedActivities = new StreamController<Activity>();
  
  Future<Activity> startChildActivity(String activityName,[Map parameters]) {
    return startActivity(getActivityDef(activityName),ActivityMode.FULL_SCREEN,parameters);
  }
  
  Future<Activity> startChildPopupActivity(String activityName,[Map parameters]) {
    return startActivity(getActivityDef(activityName),ActivityMode.POPUP,parameters);
  }
  
  Future<Activity> startRootActivity(String activityName,[Map parameters]) {
    return closeAllActivity().then((a){
      return startActivity(getActivityDef(activityName),ActivityMode.FULL_SCREEN,parameters);
    });
  }
  
  Future<Activity> startActivity(ActivityDef activityDef, ActivityMode mode, [Map parameters]) {
      
    Activity parentActivity = activityStack.isNotEmpty?activityStack.last:null;
    Activity newActivity = new Activity(activityDef,parentActivity,this);
    newActivity.parameters = parameters;
    newActivity.activityMode = mode;
    
    Future<Activity> task = new Future.sync(()=>newActivity);
    if (parentActivity!=null) {
      task = task.then((a){
        return parentActivity.pause();
      });
    }
    task = task.then((a){
      return newActivity.start();
    });
    task = task.then((a){
      startedActivities.add(a);
    });
    task = task.then((a){
      activityStack.add(newActivity);
      return newActivity;
    });
    return task;
  }
  
  Future closeAllActivity() { 
    return closeActivity().then((a){
      if (a!=null) {
        return closeAllActivity(); 
      }
    });    
  }
  
  Future<Activity> closeActivity() { 
    if (activityStack.isNotEmpty) {
      Activity current = activityStack.last;
      return current.close().then((a){
        activityStack.remove(a);
      }).then((a){
        if (activityStack.isNotEmpty) {
          return activityStack.last.resume();
        }
      });
    } else {
      return new Future.sync(()=>null);
    }
  }
  
  void registerActivityDef(ActivityDef activityDef) {
    this.activityRegistry.registerActivityDef(activityDef);
  }
  
  ActivityDef getActivityDef(String activityName) {
    return this.activityRegistry.getActivityDef(activityName);
  }
  
  Stream<Activity> get startedActivitiesStream => startedActivities.stream;
}

class ActivityRegistry {
  
  Map<String,ActivityDef> data = new Map();
  
  void registerActivityDef(ActivityDef activityDef) {
    if (data.containsKey(activityDef.name)) {
      throw new StateError("Una Definizione di activity con nome: ${activityDef.name} è già presente.");
    }
    data[activityDef.name] = activityDef;
  }
  
  ActivityDef getActivityDef(String activityName) {
    return data[activityName];
  }
  
  void registerActivities(Element activitiesInfos) {
    List<Node> activityDefs = activitiesInfos.querySelectorAll("[data-specs='activityDef']");
    activityDefs.forEach((n){
       Element e = n as Element;
       String name = e.attributes['name'];
       String title = e.attributes['title'];
       String element = e.attributes['element'];
       registerActivityDef(new ActivityDef(name,title,element));
    });
  }
  
}

class ActivityDef {
  
  String name;
  String label;
  String polyTag;
  bool closable;
   
  ActivityDef(this.name,this.label,this.polyTag,[bool this.closable=true]);
  
}

class Activity {
 
  ActivityDef activitydef;
  ActivityManager activityManager;
  Activity parent;
  ActivityState state = ActivityState.CREATED;
  HtmlElement view;
  ActivityHostElement activityHostElement;
  
  ActivityComponent component;

  //Parametri passati da chi lancia l'activity
  Map parameters;
  
  ActivityMode activityMode;
  
  Completer closingCompleter = new Completer();
  dynamic returnValue;
  
  
  Activity(this.activitydef,this.parent,this.activityManager);
  
  String get title => this.activitydef.label;
  
  bool isRoot() => this.parent==null; 
    
  Future<Activity> start() {
    return _createView().then((v){
      view = v;
      state = ActivityState.STARTED;
      component.fire("activity-started",detail:{});
      return this;
    });
  }
  
  Future whenClose(onValue(retVal)) {
    return closingCompleter.future.then(onValue);
  }
  
  Future<Activity> pause() {
    state = ActivityState.PAUSED;
    component.fire("activity-paused",detail:{});
    return new Future.sync(()=>this);
  }
  
  Future<Activity> close() {
    state = ActivityState.TERMINATED;
    activityHostElement.remove(this);
    view=null;
    activityHostElement=null;
    closingCompleter.complete(returnValue);
    return new Future.sync(()=>this);
  }
  
  Future<Activity> resume() {
    if (state!=ActivityState.PAUSED) {
      throw new StateError("Resuming not paused Activity!!");
    }
    state = ActivityState.STARTED;
    component.fire("activity-resumed",detail:{});
    return new Future.sync(()=>this);
  }
  
  /**
   * API per implementatore
   */
  void closeWithValue(returnValue) {
    this.returnValue = returnValue;
    activityManager.closeActivity();
  }
  
  /* internals */
  
  Future<HtmlElement> _createView() {
     
      HtmlElement view;
      view = new DivElement();
      view.classes.add("activityView");
      
      Element element = new Element.tag(this.activitydef.polyTag);
      component = (element as ActivityComponent);
      component.activity = this;
      element.classes.add("activity");
      view.append(element);
     
      return new Future.sync(()=>view);
    }
  
  void showInto(ActivityHostElement activityHostElement) {    
    this.activityHostElement = activityHostElement;
    this.activityHostElement.display(this);    
  }
  
}

class ActivityState {
  static final ActivityState CREATED = new ActivityState();
  static final ActivityState STARTED = new ActivityState();
  static final ActivityState PAUSED = new ActivityState();
  static final ActivityState TERMINATED = new ActivityState();
}

class ActivityMode {
  static final ActivityMode FULL_SCREEN = new ActivityMode();
  static final ActivityMode POPUP = new ActivityMode();
}

/**
 * Classe da estendere per definire una nuova activity
 */
class ActivityComponent extends PolymerElement {
  
  ActivityComponent.created() : super.created();
  
  @observable Activity activity;
  
}

abstract class ActivityHostElement {
  
  void display(Activity activity);
  
  void remove(Activity activity);
  
}
