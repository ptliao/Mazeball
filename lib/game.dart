import 'dart:ui';
import 'package:box2d_flame/box2d.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mazeball/Elements/ball.dart';
import 'package:mazeball/Views/base/baseView.dart';
import 'package:mazeball/Views/base/viewSwtichMessage.dart';
import 'package:mazeball/Views/viewManager.dart';
import 'package:wakelock/wakelock.dart';

class GameWidget extends StatefulWidget {
  @override
  _GameWidgetState createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  MazeBallGame game;

  _GameWidgetState() {
    game = new MazeBallGame();
  }

  @override
  void initState() {
    super.initState();
    game.pop = () {
      Navigator.pop(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        game.widget,
      ]),
    );
  }
}

class Contan extends ContactListener {
// 开始碰撞后操作碰撞userData来改变数据
  @override
  void beginContact(Contact contact) {
    // TODO: implement beginContact
    Body bodyA = contact.fixtureA.getBody();
    Body bodyB = contact.fixtureB.getBody();
    if(bodyA.userData is Ball){

    }
//    b2Body* bodyA = contact->GetFixtureA()->GetBody();
//    b2Body* bodyB = contact->GetFixtureB()->GetBody();
//    CCSprite* spriteA = (CCSprite*)bodyA->GetUserData();
//    CCSprite* spriteB = (CCSprite*)bodyB->GetUserData();
//
//    //更改碰撞体颜色
//    if (spriteA != NULL && spriteB != NULL)
//    {
//    spriteA.color = ccMAGENTA;
//    spriteB.color = ccMAGENTA;
//    }
  }

  @override
  void endContact(Contact contact) {
    // TODO: implement endContact
  }

  @override
  void postSolve(Contact contact, ContactImpulse impulse) {
    // TODO: implement postSolve
  }

  @override
  void preSolve(Contact contact, Manifold oldManifold) {
    // TODO: implement preSolve
  }
}

class MazeBallGame extends Game {
  //Needed for Box2D
  static const int WORLD_POOL_SIZE = 100;
  static const int WORLD_POOL_CONTAINER_SIZE = 10;

  //Main physic object -> our game world
  World world;

  //Zero vector -> no gravity
// 设置重力加速度 0.02
  final Vector2 _gravity = new Vector2(0, -0.02); //Vector2.zero();
  //Scale factore for our world
  final int scale = 5;

  //Size of the screen from the resize event
  Size screenSize;

  //Rectangle based on the size, easy to use
  Rect _screenRect;

  Rect get screenRect => _screenRect;

  //Handle views and transition between
  ViewManager _viewManager;

  bool pauseGame = false;
  bool blockResize = false;

  MazeBallGame({GameView startView = GameView.Playing}) {
    world = new World.withPool(
        _gravity, DefaultWorldPool(WORLD_POOL_SIZE, WORLD_POOL_CONTAINER_SIZE));
    world.setContactListener(Contan());
    initialize(startView: startView);
  }

  //Initialize all things we need, devided by things need the size and things without
  Future initialize({GameView startView = GameView.Playing}) async {
    //Call the resize as soon as flutter is ready
    resize(await Flame.util.initialDimensions());
    _viewManager = ViewManager(this);
    _viewManager.changeView(startView);
  }

  void resize(Size size) {
    if (blockResize && screenSize != null) {
      return;
    }
    //Store size and related rectangle
    screenSize = size;
    _screenRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    super.resize(size);
  }

  @override
  void render(Canvas canvas) {
    //If no size information -> leave
    if (screenSize == null || pauseGame) {
      return;
    }
    //Save the canvas and resize/scale it based on the screenSize
    canvas.save();
    canvas.scale(screenSize.width / scale);
    _viewManager?.render(canvas);
    //Finish the canvas and restore it to the screen
    canvas.restore();
  }

  @override
  void update(double t) {
    if (screenSize == null || pauseGame) {
      return;
    }

    //Run any physic related calculation
    world.stepDt(t, 100, 100);
    _viewManager?.update(t);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      pauseGame = true;
      Wakelock.disable();
    } else {
      Wakelock.enable();
      pauseGame = false;
    }
  }

  void sendMessageToActiveState(ViewSwitchMessage message) async {
    _viewManager.activeView?.setActive(message: message);
  }

  Function() pop;
}
