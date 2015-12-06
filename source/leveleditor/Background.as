package leveleditor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class Background extends BaseUIComponent
	{
		private const LARGE_RECTANGLE_SIZE:int = 200;
		private const SMALL_RECTANGLE_SIZE:int = 20;
		
		protected var _bitmapBackground:Bitmap;

		protected var _scale:Number = 1;

		public function Background()
		{
		}
		
		override protected function inited( ):void
		{	
			draw( );
		}
		
		override protected function stageResized( ):void
		{
			draw( );
		}
		
		protected function draw( ):void
		{
			removeBitmapBackground( );

			_bitmapBackground = createBitmapBackgroundFromVectorGraphics( createVectorGraphics( ) );

			addChild( _bitmapBackground );
		}
		
		protected function removeBitmapBackground( ):void
		{
			if ( _bitmapBackground )
			{
				_bitmapBackground.bitmapData.dispose( );
				removeChild( _bitmapBackground );
				_bitmapBackground = null;
			}
		}
		
		protected function createVectorGraphics( ):Sprite
		{
			var vectorGraphics:Sprite = new Sprite;
			
			vectorGraphics.graphics.beginFill( 0x416BBB );
			vectorGraphics.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			vectorGraphics.graphics.endFill( );

			if ( this._scale > .5 )
			{
				fillVectorGraphicsWithRectangles( vectorGraphics, 1, 0x6F9FFF, .5, LARGE_RECTANGLE_SIZE * _scale );
				fillVectorGraphicsWithRectangles( vectorGraphics, 1, 0x6F9FFF, .1, SMALL_RECTANGLE_SIZE * _scale );
			}
			
			return vectorGraphics;
		}
		
		protected function fillVectorGraphicsWithRectangles( vectorGraphics, lineStyle, lineColor, lineAlpha, rectangleSize:Number ):void
		{
			vectorGraphics.graphics.lineStyle( lineStyle, lineColor, lineAlpha );
			var col:int = stage.stageWidth / rectangleSize + 1;
			var row:int = stage.stageHeight / rectangleSize + 1;
			
			for ( var i:int = 0; i < col; i++ )
			{
				for ( var j:int = 0; j < row; j++ )
				{
					vectorGraphics.graphics.drawRect( i * rectangleSize, j * rectangleSize, rectangleSize, rectangleSize );
				}
			}
		}
		
		protected function createBitmapBackgroundFromVectorGraphics( vectorGraphics:Sprite ):Bitmap
		{
			var baseBitmapData:BitmapData = new BitmapData( vectorGraphics.width, vectorGraphics.height, false, 0 )
			baseBitmapData.draw( vectorGraphics );
			
			vectorGraphics.graphics.clear( );
			vectorGraphics = null;
			
			return new Bitmap( baseBitmapData );
		}

		public function setScale( scale:Number ):void
		{
			this._scale = scale;

			this.draw();
		}
	}
}