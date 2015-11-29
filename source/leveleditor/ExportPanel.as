package leveleditor
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import leveleditor.data.LevelData;
	import leveleditor.events.ImportEvent;
	import leveleditor.events.MenuEvent;

	public class ExportPanel extends BaseUIComponent
	{
		private var background:Sprite;

		private var dialog:ExportDialog;
		
		public function ExportPanel( )
		{
			hide( );
		}
		
		override protected function inited( ):void
		{
			addChild( background = new Sprite );
			background.graphics.beginFill( 0x000000, .5 );
			background.graphics.drawRect( 0, 0, stage.stageWidth, stage.stageHeight );
			background.graphics.endFill( );
			
			addChild( dialog = new ExportDialog );
			dialog.outputText.text = '';
			dialog.largeCloseButton.addEventListener( MouseEvent.CLICK, closeButtonHandler );
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
		
		protected function convertLevelDataToJSONString( levelData:LevelData ):String
		{
			var data:Object = {};
			
			data.groundPoints = levelData.groundPoints;
			data.starPoints = levelData.starPoints;
			data.bridgePoints = levelData.bridgePoints;
			data.startPoint = levelData.startPoint;
			data.finishPoint = levelData.finishPoint;
				
			return JSON.stringify( data );
		}
		
		public function show( levelData:LevelData ):void
		{
			visible = true;
			
			dialog.outputText.text = convertLevelDataToJSONString( levelData );
			
			stage.focus = dialog.outputText;
			( dialog.outputText as TextField ).setSelection( 0, dialog.outputText.text.length );
		}

		public function hide( ):void
		{
			visible = false;
		}
		
	}
}