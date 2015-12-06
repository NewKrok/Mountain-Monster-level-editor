package leveleditor
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class BaseUIComponent extends Sprite
	{
		public static const PIXEL_SNAP_VALUE:int = 20;
		
		private var _lastStageSize:Point = new Point;
		
		public function BaseUIComponent( )
		{
			addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
		}
		
		private function addedToStageHandler( e:Event ):void
		{
			_lastStageSize.setTo( stage.stageWidth, stage.stageHeight );
			
			removeEventListener( Event.ADDED_TO_STAGE, inited );
			stage.addEventListener( Event.RESIZE, onStageResizeHandler );
			
			inited( );
		}
		
		private function onStageResizeHandler( e:Event ):void
		{
			stageResized( );
			
			_lastStageSize.setTo( stage.stageWidth, stage.stageHeight );
		}
		
		protected function inited( ):void
		{
		}
		
		protected function stageResized( ):void
		{
		}
		
		protected function get lastStageSize( ):Point
		{
			return _lastStageSize;
		}
		
		public static function snapToGrid( position:Number, snapSize:Number = PIXEL_SNAP_VALUE ):int
		{
			return Math.round( position / snapSize ) * snapSize;
		}
	}
}