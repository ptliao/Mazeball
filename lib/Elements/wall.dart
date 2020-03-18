import 'dart:ui';
import 'package:box2d_flame/box2d.dart';
import 'package:mazeball/game.dart';
import 'package:mazeball/helper.dart';

class Wall {
  //Ref to our game object
  final MazeBallGame game;
  //Size of the ball, radius in meter
  static final double wallWidth = 5;
  //Physic objects
  Body body;
  PolygonShape shape;
  //Drawing
  Path _path;
  Paint _paint;

  Wall(this.game, Vector2 startPoint, Vector2 endPoint) {
    final scaleFactor = game.screenSize.width / game.scale;
    //Build the object as a vector2 list based on start and end
    var shapAsVectorList = _buildShapVectorList(startPoint, endPoint);
    //Box2D part
    shape = PolygonShape();
    //shape.setAsEdge(Vector2.zero(), scaleVectoreBy(endPoint,scaleFactor));
    shape.set(shapAsVectorList, shapAsVectorList.length);
    BodyDef bd = BodyDef();
    bd.linearVelocity = Vector2.zero();
    bd.position = scaleVectoreBy(startPoint, scaleFactor);
    //Static objects are not effected by gravity but have collisions
    bd.type = BodyType.STATIC;
    body = game.world.createBody(bd);
    body.userData = this; //save a ref to the current object
    //Define body properties like weight and density
//    https://blog.csdn.net/linmy1211/article/details/39080875
    FixtureDef fd = FixtureDef();
    // fixture的密度用来计算父物体的质量属性。密度值可以为零或者是整数。你所有的fixture都应该使用相似的密度，这样做可以改善物体的稳定性。 当你添加一个fixture时，物体的质量会自动调整。
    fd.density = 20;
    // 恢复可以使对象弹起。恢复的值通常设置在0到1之间。想象一个小球掉落到桌子上，值为0表示着小球不会弹起, 这称为非弹性碰撞。值为1表示小球的速度跟原来一样，只是方向相反, 这称为完全弹性碰撞。
    fd.restitution = 0;
     //摩擦可以使对象逼真地沿其它对象滑动。Box2D支持静摩擦和动摩擦,两者都使用相同的参数。
    // 摩擦在Box2D中会被精确地模拟,摩擦力的强度与正交力(称之为库仑摩擦)成正比。
    // 摩擦参数经常会设置在0到1之间, 也能够是其它的非负数，0意味着没有摩擦, 1会产生强摩擦。
    // 当计算两个形状之间的摩擦时,Box2D必须联合两个形状的摩擦参数。这是通过以下公式完成的:
    fd.friction = 0;

    fd.shape = shape;
    body.createFixtureFromFixtureDef(fd);
    //Create a Path for drawing based on vecotor list, rquies a convert to Offset
    _path = Path();
    _path.addPolygon(
        shapAsVectorList.map((vector) => Offset(vector.x, vector.y)).toList(),
        false);
    //Painter, white walls
    _paint = Paint();
    _paint.color = Color(0xffffffff);
  }

  List<Vector2> _buildShapVectorList(Vector2 start, Vector2 end) {
    final scaleFactor = game.screenSize.width / game.scale;
    var result = new List<Vector2>();
    //Left side corner starts at (0,0) the canvas will be moved to start point
    result.add(Vector2.zero());
    //Vertical wall if start point Y is less then end point Y other wise horizontal wall
    if (start.y < end.y) {
      var endY = (start.y - end.y).abs();
      result.add(scaleVectoreBy(Vector2(0, endY), scaleFactor));
      result.add(scaleVectoreBy(Vector2(wallWidth, endY), scaleFactor));
      result.add(scaleVectoreBy(Vector2(wallWidth, 0), scaleFactor));
    } else if (start.x < end.x) {
      var endX = (start.x - end.x).abs();
      result.add(scaleVectoreBy(Vector2(endX, 0), scaleFactor));
      result.add(scaleVectoreBy(Vector2(endX, wallWidth), scaleFactor));
      result.add(scaleVectoreBy(Vector2(0, wallWidth), scaleFactor));
    }
    return result; //list of 4 points describing the edges of the wall
  }

  void render(Canvas canvas) {
    canvas.save();
    //Canvas (0,0) will be the start point of the wall -> easier to draw
    canvas.translate(body.position.x, body.position.y);
    canvas.drawPath(_path, _paint);
    canvas.restore();
  }

  //A wall has nothing todo, it just sits there ... it's a wall so no update
  
}
