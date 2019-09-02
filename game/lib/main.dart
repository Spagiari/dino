import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/sprite.dart';
import 'dart:math';

Future main() async {
  await Flame.util.setOrientation(DeviceOrientation.landscapeLeft);
  Size size = await Flame.util.initialDimensions();

  MyGame game = MyGame(size);
  runApp(game.widget);
  Flame.util.addGestureRecognizer(TapGestureRecognizer()..onTap = () => game.tap());
}

class Dino extends AnimationComponent {
  static const G = 600.0;
  static const J = -400.0;

  static const S = 3.0;
  static const W = 15.0;
  static const H = 17.0;

  double initialY;
  double ySpeed = 0.0;

  Dino(Size size) : super.sequenced(S * W, S * H, 'dino.png', 6, textureWidth: W, textureHeight: H) {
    x = size.width / 3;
    y = initialY = size.height / 2 - this.height;
  }

  @override
  void update(double t) {
    if (ySpeed != 0.0) {
      y += ySpeed * t - G * t  * t / 2;
      ySpeed += G * t;
    }
    if (y >= initialY) {
      y = initialY;
      ySpeed = 0.0;
    }
    super.update(t);
  }

  void jump() {
    if (ySpeed == 0.0) {
      ySpeed = J;
    }
  }

  @override
  int priority() => 2;
}

class Bg extends Component with Resizable {

  @override
  void render(Canvas c) {
    c.drawRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height / 2), Paint()..color = Color(0xFF76D7EA));
    c.drawRect(Rect.fromLTWH(0.0, size.height / 2, size.width, size.height), Paint()..color = Color(0xFF6ABE30));
  }

  @override
  void update(double t) {}

  @override
  int priority() => 1;
}

class Cactus extends SpriteComponent {
	double xSpeed = 0.0;
	bool toDestroy = false;

  Cactus(Size size, double xSpeed): super.rectangle(15.0*2, 17.0 *2, 'cactus.png') {
            this.angle = 0.0;
	    this.x = size.width - this.width;
	    this.y = size.height / 2 - this.height;
	    this.xSpeed = xSpeed;
        }
  
  @override
  void update(double t) {
    if (x >= 0)
    {
        x-= xSpeed * t;
    }
    super.update(t);
  }

  @override
  bool destroy() {
    return toDestroy;
  }

  void fire() {
	toDestroy = true;
  }
  
  @override
  int priority() => 3;
}

class MyGame extends BaseGame {
  Dino dino;
  Random random = Random();
  List<Cactus> listCactus;

  MyGame(Size size) {
    listCactus = new List();
    Cactus cactus;

    this.size = size;
    add(dino = Dino(size));
    add(Bg());
    add(cactus = Cactus(size, 75));

    listCactus.add(cactus);
    
    // in the render method
  }

  @override
  void update(double t) {
    final colisions = colisionDetect(listCactus);
    deleteCactus(colisions);
    cactusGenerator();
    super.update(t);
  }
  
  List<Cactus> colisionDetect(List<Cactus> list) {
    List<Cactus> colisions = new List();

    for (final i in list)
    {
	if (i.x <= 0)
	{
		colisions.add(i);
	}
	else if (dino.x < i.x + i.width &&
	    dino.x + dino.width > i.x &&
	    dino.y < i.y + i.height &&
	    dino.y + dino.height > i.y)
	{
	    print('Colision Detected');
	    colisions.add(i);
	    print(i);
	}
    }
    return colisions;
  }

  void deleteCactus(List<Cactus> cactus) {
      for (final i in cactus) {
	      listCactus.remove(i);
	      i.fire();
	      print(i.destroy());
      }
  }

  void cactusGenerator()
  {
	  if (random.nextInt(600) > 590)
	  {
		  Cactus cactus;
    add(cactus = Cactus(size, 75));

    listCactus.add(cactus);


	  }
  }

  void tap() {
    dino.jump();
  }
}
