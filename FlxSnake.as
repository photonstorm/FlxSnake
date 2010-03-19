/**
 * FlxSnake for Flixel 2.23 - 19th March 2010
 * 
 * Cursor keys to move. Red squares are fruit. Snake can wrap around screen edges.
 * 
 * @author Richard Davey, Photon Storm <rich@photonstorm.com>
 */

package  
{
	import org.flixel.*;
	
	import flash.utils.getTimer;
	
	public class FlxSnake extends FlxState
	{
		[Embed(source = "org/flixel/data/beep.mp3")] protected var SndBeep:Class;
		[Embed(source = "org/flixel/data/flixel.mp3")] protected var SndMusic:Class;
		
		private var score:FlxText;
		private var fruit:FlxSprite;
		
		private var isAlive:Boolean;
		private var snakeHead:FlxSprite;
		private var snakeBody:FlxGroup;
		private var addSegment:Boolean;
	
		private var nextMove:int;
		private var snakeSpeed:int;
		
		public function FlxSnake() 
		{
		}
		
		override public function create():void
		{
			isAlive = true;
			addSegment = false;
			snakeSpeed = 150;
			nextMove = getTimer() + snakeSpeed * 2;
			
			//	Let's create the body pieces, we'll start with 3 pieces plus a head. Each piece is 8x8
			snakeBody = new FlxGroup();
			
			spawnNewBody(64 + 8, FlxG.height / 2);
			spawnNewBody(64 + 16, FlxG.height / 2);
			spawnNewBody(64 + 24, FlxG.height / 2);
			spawnNewBody(64 + 32, FlxG.height / 2);
			
			//	Get the head piece from the body For easy later reference, and also visually change the colour a little
			snakeHead = snakeBody.members[0];
			snakeHead.createGraphic(8, 8, 0xFF00FF00);
			snakeHead.facing = FlxSprite.LEFT;
			
			//	Something to eat
			fruit = new FlxSprite(0, 0).createGraphic(8, 8, 0xFFFF0000);
			placeFruit();
			
			//	Simple score
			score = new FlxText(0, 0, 200);
			FlxG.score = 0;
			
			add(snakeBody);
			add(fruit);
			add(score);
		}
		
		override public function update():void
		{
			super.update();
			
			if (isAlive)
			{
				//	Collision Checks
				
				//	1) First did we hit the fruit?
				if (snakeHead.overlaps(fruit))
				{
					FlxG.score += 10;
					placeFruit();
					addSegment = true;
					FlxG.play(SndBeep);
					
					//	Get a little faster each time
					if (snakeSpeed > 50)
					{
						snakeSpeed -= 10;
					}
				}
				
				//	2) Did we hit ourself? :)
				//	We set the deadSnake callback to stop the QuadTree killing both objects, as we want them on-screen with the game over message
				FlxU.overlap(snakeHead, snakeBody, deadSnake);
				
				score.text = "Score: " + FlxG.score.toString();
				
				if (FlxG.keys.UP)
				{
					snakeHead.facing = FlxSprite.UP;
				}
				else if (FlxG.keys.DOWN)
				{
					snakeHead.facing = FlxSprite.DOWN;
				}
				else if (FlxG.keys.LEFT)
				{
					snakeHead.facing = FlxSprite.LEFT;
				}
				else if (FlxG.keys.RIGHT)
				{
					snakeHead.facing = FlxSprite.RIGHT;
				}
				
				if (getTimer() > nextMove)
				{
					moveSnakeParts();
					nextMove = getTimer() + snakeSpeed;
				}
			}
			else
			{
				score.text = "GAME OVER! Score: " + FlxG.score.toString();
			}
		}
		
		private function deadSnake(object1:FlxObject, object2:FlxObject):void
		{
			isAlive = false;
			FlxG.play(SndMusic);
		}
		
		private function placeFruit(object1:FlxObject = null, object2:FlxObject = null):void
		{
			//	Pick a random place to put the fruit down
			
			fruit.x = int(Math.random() * (FlxG.width / 8) - 1) * 8;
			fruit.y = int(Math.random() * (FlxG.height / 8) - 1) * 8;
			
			//	Check that the coordinates we picked aren't already covering the snake, if they are then run this function again
			FlxU.overlap(fruit, snakeBody, placeFruit);
		}
		
		private function moveSnakeParts():void
		{
			//	Move the head in the direction it is facing
			//	If it hits the edge of the screen it wraps around
			
			var oldX:int = snakeHead.x;
			var oldY:int = snakeHead.y;
			
			if (addSegment)
			{
				var addX:int = snakeBody.members[snakeBody.members.length - 1].x;
				var addY:int = snakeBody.members[snakeBody.members.length - 1].y;
			}
			
			switch (snakeHead.facing)
			{
				case FlxSprite.LEFT:
					if (snakeHead.x == 0)
					{
						snakeHead.x = FlxG.width - 8;
					}
					else
					{
						snakeHead.x -= 8;
					}
					break;
					
				case FlxSprite.RIGHT:
					if (snakeHead.x == FlxG.width - 8)
					{
						snakeHead.x = 0;
					}
					else
					{
						snakeHead.x += 8;
					}
					break;
					
				case FlxSprite.UP:
					if (snakeHead.y == 0)
					{
						snakeHead.y = FlxG.height - 8;
					}
					else
					{
						snakeHead.y -= 8;
					}
					break;
					
				case FlxSprite.DOWN:
					if (snakeHead.y == FlxG.height - 8)
					{
						snakeHead.y = 0;
					}
					else
					{
						snakeHead.y += 8;
					}
					break;
			}
			
			//	And now interate the movement down to the rest of the body parts
			//	The easiest way to do this is simply to work our way backwards through the body pieces!
			
			for (var s:int = snakeBody.members.length - 1; s > 0; s--)
			{
				//	We need to keep the x/y/facing values from the snake part, to pass onto the next one in the chain
				if (s == 1)
				{
					snakeBody.members[s].x = oldX;
					snakeBody.members[s].y = oldY;
				}
				else
				{
					snakeBody.members[s].x = snakeBody.members[s - 1].x;
					snakeBody.members[s].y = snakeBody.members[s - 1].y;
				}
			}
			
			//	Are we adding a new snake segment? If so then put it where the final piece used to be
			if (addSegment)
			{
				spawnNewBody(addX, addY);
				addSegment = false;
			}
			
		}
		
		private function spawnNewBody(_x:int, _y:int):void
		{
			snakeBody.add(new FlxSprite(_x, _y).createGraphic(8, 8, 0xFF008000));
		}
		
	}

}