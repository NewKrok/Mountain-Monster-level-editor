package leveleditor
{
	import flash.events.MouseEvent;

	public class SizeHelper extends BaseUIComponent
	{
		public function SizeHelper()
		{
		}
		
		override protected function inited( ):void
		{
			super.inited( );
			
			buttonMode = true;
			
			resetPosition( );
			
			addEventListener( MouseEvent.MOUSE_DOWN, startDragHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, stopDragHandler );
		}
		
		protected function startDragHandler( e:MouseEvent ):void
		{
			startDrag( );
		}
		
		protected function stopDragHandler( e:MouseEvent ):void
		{
			resetPosition( );
		}
		
		override protected function stageResized( ):void
		{
			resetPosition( );
		}
		
		protected function resetPosition( ):void
		{
			x = 5;
			y = stage.stageHeight - height - 5;
		}
	}
}