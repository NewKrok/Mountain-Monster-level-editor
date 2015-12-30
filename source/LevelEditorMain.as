package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	import leveleditor.Background;
	import leveleditor.DeviceView;
	import leveleditor.EditorLibrary;
	import leveleditor.EditorWorld;
	import leveleditor.ExportPanel;
	import leveleditor.ImportPanel;
	import leveleditor.Menu;
	import leveleditor.SizeHelper;
	import leveleditor.ZoomView;
	import leveleditor.events.EditorLibraryEvent;
	import leveleditor.events.EditorWorldEvent;
	import leveleditor.events.ImportEvent;
	import leveleditor.events.MenuEvent;
	
	import net.fpp.static.FPPContextMenu;
	
	import rv2.keyboard.KeyboardOperator;
	
	public class LevelEditorMain extends Sprite
	{
		private var _background:Background;
		private var _editorWorld:EditorWorld;
		private var _deviceView:DeviceView;
		private var _sizeHelper:SizeHelper;
		private var _zoomView:ZoomView;
		private var _menu:Menu;
		private var _editorLibrary:EditorLibrary;
		private var _importPanel:ImportPanel;
		private var _exportPanel:ExportPanel;
		
		public function LevelEditorMain()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			addEventListener( Event.ADDED_TO_STAGE, inited );
			
			FPPContextMenu.create( this );
		}

		private function inited( e:Event ):void
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

			this._editorLibrary = new EditorLibrary();
			this._editorLibrary.addEventListener( EditorLibraryEvent.OPEN_REQUEST, onEditorLibraryOpenHandler )
			this._editorLibrary.addEventListener( EditorLibraryEvent.ADD_ELEMENT_TO_WORLD_REQUEST, onAddelementToWorldRequestHandler )
			this.addChild( this._editorLibrary );
			
			_editorWorld.jumpToStart( _deviceView.getCurrentDeviceViewPort( ) );
			this._editorWorld.addEventListener( EditorWorldEvent.ON_VIEW_RESIZE, this.onEditorWorldResize );
			
			addChild( _importPanel = new ImportPanel );
			_importPanel.addEventListener( ImportEvent.DATA_IMPORTED, onDataImportedHandler );
			_importPanel.addEventListener( MenuEvent.CLOSE_REQUEST, onCloseImportPanelHandler );
			
			addChild( _exportPanel = new ExportPanel );
			_exportPanel.addEventListener( MenuEvent.CLOSE_REQUEST, onCloseExportPanelHandler );
		}

		private function onImportRequestHandler( e:MenuEvent ):void
		{
			_importPanel.show( );
			KeyboardOperator.pause( );
		}

		private function onEditorWorldResize( e:EditorWorldEvent ):void
		{
			var zoomValue:Number = e.data as Number;

			this._background.setScale( zoomValue );

			_zoomView.setZoom( zoomValue );
		}

		private function onDataImportedHandler( e:ImportEvent ):void
		{
			_editorWorld.loadLevel( e.levelData );
			
			_editorWorld.jumpToStart( _deviceView.getCurrentDeviceViewPort( ) );
			
			onCloseImportPanelHandler( new MenuEvent( MenuEvent.CLOSE_REQUEST ) );
		}

		private function onCloseImportPanelHandler( e:MenuEvent ):void
		{
			_importPanel.hide( );
			KeyboardOperator.unPause( );
		}

		private function onExportRequestHandler( e:MenuEvent ):void
		{
			_exportPanel.show( _editorWorld.getLevelData( ) );
			KeyboardOperator.pause( );
		}

		private function onCloseExportPanelHandler( e:MenuEvent ):void
		{
			_exportPanel.hide( );
			KeyboardOperator.unPause( );
		}

		private function onChangeCameraVisibilityHandler( e:MenuEvent ):void
		{
			_deviceView.showNextViewport( );
		}

		private function onJumpToStartHandler( e:MenuEvent ):void
		{
			_editorWorld.jumpToStart( _deviceView.getCurrentDeviceViewPort( ) );
		}

		private function onJumpToEndHandler( e:MenuEvent ):void
		{
			_editorWorld.jumpToEnd( _deviceView.getCurrentDeviceViewPort( ) );
		}

		private function zoomInHandler( e:MenuEvent ):void
		{
			_editorWorld.zoomIn();
		}

		private function zoomOutHandler( e:MenuEvent ):void
		{
			_editorWorld.zoomOut();
		}

		private function onSetControlToSelectHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_SELECT );
		}

		private function onSetControlToAddNodeHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_ADD_NODE );
			this.closeEditorLibrary();
		}

		private function onSetControlToRemoveNodeHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_REMOVE_NODE );
			this.closeEditorLibrary();
		}

		private function onSetControlToAddStarHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_ADD_STAR );
			this.closeEditorLibrary();
		}

		private function onSetControlToAddBridgeHandler( e:MenuEvent ):void
		{
			_editorWorld.setControl( EditorWorld.CONTROL_TYPE_ADD_BRIDGE );
			this.closeEditorLibrary();
		}

		private function onEditorLibraryOpenHandler( e:EditorLibraryEvent ):void
		{
			this._menu.reset();
		}

		private function closeEditorLibrary():void
		{
			if ( this._editorLibrary )
			{
				this._editorLibrary.closeLibrary();
			}
		}

		private function onAddelementToWorldRequestHandler( e:EditorLibraryEvent ):void
		{
			this._editorWorld.addLibraryElement( e.libraryElementVO );
		}
	}
}