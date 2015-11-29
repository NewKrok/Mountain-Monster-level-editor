package leveleditor
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class DeviceView extends BaseUIComponent
	{
		private var DEVICE_VIEWPORTS:Vector.<Point> = new <Point>[
			null,					// no device
			new Point( 960, 640 ),	// iPhone 4
			new Point( 1136, 640 ), // iPhone 5
			new Point( 1024, 768 )	// iPad 2
		];
		
		private var DEVICE_NAMES:Vector.<String> = new <String>[
			'',
			'iPhone 4 / 4s',
			'iPhone 5 / 5s',
			'iPad 2'
		];
			
		protected var currentViewportIndex:int = 0;
			
		protected var _view:Sprite;
		
		protected var deviceName:TextField;
		
		public function DeviceView()
		{
		}
		
		override protected function inited( ):void
		{
			addChild( _view = new Sprite );
			createDeviceName( );
			
			mouseChildren = false;
			mouseEnabled = false;

			draw( );
		}
		
		protected function createDeviceName( ):void
		{
			deviceName = new TextField( );
			deviceName.autoSize = 'right';
			deviceName.alpha = .3;
			
			var textFormat:TextFormat = new TextFormat( );
			textFormat.color = 0xFFFFFF;
			textFormat.size = 12;
			textFormat.font = 'verdana';
			
			deviceName.defaultTextFormat = textFormat;
			
			addChild( deviceName );
		}
		
		override protected function stageResized( ):void
		{
			draw( );
		}
		
		protected function draw( ):void
		{
			_view.graphics.clear( );
			
			if ( DEVICE_VIEWPORTS[currentViewportIndex] != null )
			{
				var currentViewPort:Rectangle = getCurrentDeviceViewPort( );
				
				_view.graphics.beginFill( 0, .3 );
				_view.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
				_view.graphics.lineStyle( 2, 0xFFFFFF, 1 );
				_view.graphics.drawRect(
					currentViewPort.x,
					currentViewPort.y,
					currentViewPort.width,
					currentViewPort.height
				);
				_view.graphics.endFill( );
				
				deviceName.text = DEVICE_NAMES[currentViewportIndex];
				deviceName.x = currentViewPort.x + currentViewPort.width - deviceName.width;
				deviceName.y = currentViewPort.y - deviceName.height;
			}
			else
			{
				deviceName.text = '';
			}
		}
		
		public function showNextViewport( ):void
		{
			currentViewportIndex++;
			if ( currentViewportIndex > DEVICE_VIEWPORTS.length - 1 )
			{
				currentViewportIndex = 0;
			}
			
			draw( );
		}
		
		public function getCurrentDeviceViewPort( ):Rectangle
		{
			if ( DEVICE_VIEWPORTS[currentViewportIndex] != null )
			{
				return new Rectangle( 
					snapToGrid( stage.stageWidth / 2 - DEVICE_VIEWPORTS[currentViewportIndex].x / 2 ),
					snapToGrid( stage.stageHeight / 2 - DEVICE_VIEWPORTS[currentViewportIndex].y / 2 ),
					snapToGrid( DEVICE_VIEWPORTS[currentViewportIndex].x ),
					snapToGrid( DEVICE_VIEWPORTS[currentViewportIndex].y )
				);
			}
			else
			{
				return new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
			}
		}		
	}
}