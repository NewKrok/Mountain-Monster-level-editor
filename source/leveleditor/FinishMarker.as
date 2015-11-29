package leveleditor
{
	import flash.events.MouseEvent;

	public class FinishMarker extends BaseUIComponent
	{
		protected var _editorWorld:EditorWorld;
		
		public function FinishMarker( editorWorld:EditorWorld )
		{
			_editorWorld = editorWorld;
			mouseChildren = false;
		}
		
		override protected function inited( ):void
		{
			super.inited( );
			
			buttonMode = true;
			
			addEventListener( MouseEvent.MOUSE_DOWN, startDragHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, stopDragHandler );
			
			x = Math.floor( _editorWorld.width - 200 );
			y = Math.floor( _editorWorld.height / 2 );
		}
		
		protected function startDragHandler( e:MouseEvent ):void
		{
			startDrag( );
		}
		
		protected function stopDragHandler( e:MouseEvent ):void
		{
			stopDrag( );
			
			x = Math.floor( x );
			y = Math.floor( y );
		}
	}
}