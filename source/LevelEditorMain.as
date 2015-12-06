package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import leveleditor.Background;
	import leveleditor.DeviceView;
	import leveleditor.EditorWorld;
	import leveleditor.ExportPanel;
	import leveleditor.ImportPanel;
	import leveleditor.Menu;
	import leveleditor.SizeHelper;
	import leveleditor.ZoomView;
	import leveleditor.events.EditorWorldEvent;
	import leveleditor.events.ImportEvent;
	import leveleditor.events.MenuEvent;
	
	import net.fpp.static.FPPContextMenu;
	
	import rv2.keyboard.KeyboardOperator;
	
	public class LevelEditorMain extends Sprite
	{
		protected var _background:Background;
		protected var _editorWorld:EditorWorld;
		protected var _deviceView:DeviceView;
		protected var _sizeHelper:SizeHelper;
		protected var _zoomView:ZoomView;
		protected var _menu:Menu;
		protected var _importPanel:ImportPanel;
		protected var _exportPanel:ExportPanel;
		
		public function LevelEditorMain()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener( Event.ADDED_TO_STAGE, inited );
			
			FPPContextMenu.create( this );
		}
		
		protected function inited( e:Event ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, inited );
			KeyboardOperator.init( stage );
			
			addChild( _background = new Background );
			addChild( _editorWorld = new EditorWorld );
			addChild( _deviceView = new DeviceView );
			addChild( _sizeHelper = new SizeHelper( ) );
			addChild( _zoomView = new ZoomView( ) );

			_menu = new Menu;
			_menu.addEventListener( MenuEvent.IMPORT_REQUEST, onImportRequestHandler );
			_menu.addEventListener( MenuEvent.EXPORT_REQUEST, onExportRequestHandler );
			_menu.addEventListener( MenuEvent.CHANGE_CAMERA_VIEW_VISIBILITY, onChangeCameraVisibilityHandler );
			_menu.addEventListener( MenuEvent.JUMP_VIEW_TO_START_REQUEST, onJumpToStartHandler );
			_menu.addEventListener( MenuEvent.JUMP_VIEW_TO_END_REQUEST, onJumpToEndHandler );
			_menu.addEventListener( MenuEvent.ZOOM_IN_REQUEST, zoomInHandler );
			_menu.addEventListener( MenuEvent.ZOOM_OUT_REQUEST, zoomOutHandler );
			_menu.addEventListener( MenuEvent.SET_CONTROL_TO_SELECT, onSetControlToSelectHandler );
			_menu.addEventListener( MenuEvent.SET_CONTROL_TO_ADD, onSetControlToAddNodeHandler );
			_menu.addEventListener( MenuEvent.SET_CONTROL_TO_REMOVE, onSetControlToRemoveNodeHandler );
			_menu.addEventListener( MenuEvent.SET_CONTROL_TO_STAR, onSetControlToAddStarHandler );
			_menu.addEventListener( MenuEvent.SET_CONTROL_TO_BRIDGE, onSetControlToAddBridgeHandler );
			addChild( _menu );
			
			_editorWorld.jumpToStart( _deviceView.getCurrentDeviceViewPort( ) );
			this._editorWorld.addEventListener( EditorWorldEvent.ON_VIEW_RESIZE, this.onEditorWorldResize );
			
			addChild( _importPanel = new ImportPanel );
			_importPanel.addEventListener( ImportEvent.DATA_IMPORTED, onDataImportedHandler );
			_importPanel.addEventListener( MenuEvent.CLOSE_REQUEST, onCloseImportPanelHandler );
			
			addChild( _exportPanel = new ExportPanel );
			_exportPanel.addEventListener( MenuEvent.CLOSE_REQUEST, onCloseExportPanelHandler );
		}
		
		protected function onImportRequestHandler( e:MenuEvent ):void
		{
			_importPanel.show( );
			KeyboardOperator.pause( );
		}

		protected function onEditorWorldResize( e:EditorWorldEvent ):void
		{
			var zoomValue:Number = e.data as Number;

			this._background.setScale( zoomValue );

			_zoomView.setZoom( zoomValue );
		}

		protected function onDataImportedHandler( e:ImportEvent ):void
		{
			_editorWorld.loadLevel( e.levelData );
			
			_editorWorld.jumpToStart( _deviceView.getCurrentDeviceViewPort( ) );
			
			onCloseImportPanelHandler( new MenuEvent( MenuEvent.CLOSE_REQUEST ) );
		}

		protected function onCloseImportPanelHandler( e:MenuEvent ):void
		{
			_importPanel.hide( );
			KeyboardOperator.unPause( );
		}
		
		protected function onExportRequestHandler( e:MenuEvent ):void
		{
			_exportPanel.show( _editorWorld.getLevelData( ) );
			KeyboardOperator.pause( );
		}
		
		protected function onCloseExportPanelHandler( e:MenuEvent ):void
		{
			_exportPanel.hide( );
			KeyboardOperator.unPause( );
		}

		protected function onChangeCameraVisibilityHandler( e:MenuEvent ):void
		{
			_deviceView.showNextViewport( );
		}

		protected function onJumpToStartHandler( e:MenuEvent ):void
		{
			_editorWorld.jumpToStart( _deviceView.getCurrentDeviceViewPort( ) );
		}

		protected function onJumpToEndHandler( e:MenuEvent ):void
		{
			_editorWorld.jumpToEnd( _deviceView.getCurrentDeviceViewPort( ) );
		}

		protected function zoomInHandler( e:MenuEvent ):void
		{
			_editorWorld.zoomIn();
		}

		protected function zoomOutHandler( e:MenuEvent ):void
		{
			_editorWorld.zoomOut();
		}

		protected function onSetControlToSelectHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_SELECT );
		}

		protected function onSetControlToAddNodeHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_ADD_NODE );
		}
		
		protected function onSetControlToRemoveNodeHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_REMOVE_NODE );
		}

		protected function onSetControlToAddStarHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_ADD_STAR );
		}

		protected function onSetControlToAddBridgeHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_ADD_BRIDGE );
		}
	}
}