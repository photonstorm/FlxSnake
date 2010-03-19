/**
 * FlxSnake
 * @author Richard Davey
 */

package 
{
	import org.flixel.*;
		
	[SWF(width="640", height="480", frameRate="60", backgroundColor="#000000")]
	
	public class Main extends FlxGame
	{
		
		public function Main():void 
		{
			super(320, 240, FlxSnake, 2);
		}
		
	}
	
}