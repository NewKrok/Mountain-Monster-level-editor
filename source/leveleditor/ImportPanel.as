package leveleditor
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import leveleditor.data.LevelData;
	import leveleditor.events.ImportEvent;
	import leveleditor.events.MenuEvent;

	public class ImportPanel extends BaseUIComponent
	{
		private var background:Sprite;

		private var dialog:ImportDialog;
		
		public function ImportPanel( )
		{
			hide( );
		}
		
		override protected function inited( ):void
		{
			addChild( background = new Sprite );
			background.graphics.beginFill( 0x000000, .5 );
			background.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			background.graphics.endFill( );
			
			addChild( dialog = new ImportDialog );
			dialog.inputText.text = '';
			dialog.importButton.addEventListener( MouseEvent.CLICK, startImport );
			dialog.closeButton.addEventListener( MouseEvent.CLICK, closeButtonHandler );
			
			stageResized( );
		}
		
		override protected function stageResized( ):void
		{
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			dialog.x = width / 2 - dialog.width / 2;
			dialog.y = height / 2 - dialog.height / 2;
		}
		
		protected function closeButtonHandler( e:MouseEvent ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.CLOSE_REQUEST ) );
		}
		
		protected function startImport( e:MouseEvent ):void
		{
			var data:String = dialog.inputText.text;
			var levelData:LevelData;
			
			try
			{
				levelData = convertJSONDataToLevelData( JSON.parse( data ) );
			}
			catch( e:Error )
			{
				levelData = convertLegacyDataToLevelData( data );
			}
			
			dispatchEvent( new ImportEvent( ImportEvent.DATA_IMPORTED, levelData ) );
		}
		
		protected function convertJSONDataToLevelData( data:Object ):LevelData
		{
			var levelData:LevelData = new LevelData;
			
			for ( var i:uint = 0; i < data.groundPoints.length; i++ )
			{
				levelData.groundPoints.push( new Point( data.groundPoints[i].x, data.groundPoints[i].y ) );
			}
			
			for ( i = 0; i < data.starPoints.length; i++ )
			{
				levelData.starPoints.push( new Point( data.starPoints[i].x, data.starPoints[i].y ) );
			}
			
			for ( i = 0; i < data.bridgePoints.length; i++ )
			{
				levelData.bridgePoints.push( { 
					bridgeAX: data.bridgePoints[i].bridgeAX, 
					bridgeAY: data.bridgePoints[i].bridgeAY,
					bridgeBX: data.bridgePoints[i].bridgeBX,
					bridgeBY: data.bridgePoints[i].bridgeBY
				} );
			}
			
			levelData.startPoint = data.startPoint;
			levelData.finishPoint = data.finishPoint;
			
			return levelData;
		}
		
		protected function convertLegacyDataToLevelData( data:String ):LevelData
		{
			var levelData:LevelData = new LevelData;
			
			var mapLines:Array = data.split( "&" );
			
			for ( var i:uint = 0; i < mapLines.length - 1; i += 2 )
			{
				var linePoints:Array = mapLines[i].split( "<" );
				
				levelData.groundPoints.push( new Point( snapToGrid( linePoints[0] ), snapToGrid( linePoints[1] ) ) );
				levelData.groundPoints.push( new Point( snapToGrid( linePoints[2] ), snapToGrid( linePoints[3] ) ) );
			}
			
			return levelData;
		}
		
		public function show( ):void
		{
			visible = true;
			
			dialog.inputText.text = '';
		}

		public function hide( ):void
		{
			visible = false;
		}
		
	}
}