package leveleditor
{
	import flash.text.TextField;

	public class ZoomView extends BaseUIComponent
	{
		public function ZoomView()
		{
			this.setZoom( 1 );
		}
		
		override protected function inited( ):void
		{
			super.inited( );

			this.resetPosition( );

			this.mouseEnabled = false;
			this.mouseChildren = false;
		}

		public function setZoom( value:Number ):void
		{
			TextField( this.getChildByName( 'valueText' ) ).text = Math.round( value * 100 ) + ' %';
		}

		override protected function stageResized( ):void
		{
			this.resetPosition( );
		}

		protected function resetPosition( ):void
		{
			this.x = this.stage.stageWidth - this.width - 5;
			this.y = this.stage.stageHeight - this.height - 5;
		}
	}
}