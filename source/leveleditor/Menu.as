package leveleditor
{
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import leveleditor.events.MenuEvent;
	
	import rv2.keyboard.KeyboardOperator;
	import rv2.keyboard.KeyboardSetting;
	
	public class Menu extends BaseUIComponent
	{
		private var BASE_POSITION:Point = new Point( 5, 5 );
		
		public var _moveButton:SimpleButton;
		public var _importButton:SimpleButton;
		public var _exportButton:SimpleButton;
		public var _deviceViewButton:SimpleButton;
		public var _jumpToStartButton:SimpleButton;
		public var _jumpToEndButton:SimpleButton;
		public var _zoomInButton:SimpleButton;
		public var _zoomOutButton:SimpleButton;
		public var _selectionToolButton:SimpleButton;
		public var _addNodeToolButton:SimpleButton;
		public var _removeNodeToolButton:SimpleButton;
		public var _addStarToolButton:SimpleButton;
		public var _addBridgeToolButton:SimpleButton;
		
		public function Menu()
		{
			resetPosition( );
		}
		
		override protected function inited( ):void
		{
			processButtonsFromLibrary( );
			addButtonListeners( );
			addCharListeners( );
			
			this.reset();
			
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUpHandler );
		}

		public function reset():void
		{
			_selectionToolButton.dispatchEvent( new MouseEvent( MouseEvent.CLICK ) );
		}
		
		protected function processButtonsFromLibrary( ):void
		{
			for ( var i:int; i < numChildren; i++ )
			{
				var selectedButton:SimpleButton = this.getChildAt( i ) as SimpleButton;
				
				if ( selectedButton && hasOwnProperty( '_' + selectedButton.name ) )
				{
					this['_' + selectedButton.name] = selectedButton;
				}
			}
		}
		
		protected function addButtonListeners( ):void
		{
			_moveButton.doubleClickEnabled = true;
			_moveButton.addEventListener( MouseEvent.MOUSE_DOWN, onMoveButtonMouseDownHandler );
			_moveButton.addEventListener( MouseEvent.DOUBLE_CLICK, onMoveButtonClickHandler );
			
			_importButton.addEventListener( MouseEvent.CLICK, onImportRequestHandler );
			_exportButton.addEventListener( MouseEvent.CLICK, onExportRequestHandler );
			_deviceViewButton.addEventListener( MouseEvent.CLICK, onDeviceViewRequestHandler );
			_jumpToStartButton.addEventListener( MouseEvent.CLICK, onJumpToStartRequestHandler );
			_jumpToEndButton.addEventListener( MouseEvent.CLICK, onJumpToEndRequestHandler );
			_zoomInButton.addEventListener( MouseEvent.CLICK, onZoomInRequestHandler );
			_zoomOutButton.addEventListener( MouseEvent.CLICK, onZoomOutRequestHandler );
			_selectionToolButton.addEventListener( MouseEvent.CLICK, onSelectNodeRequestHandler );
			_addNodeToolButton.addEventListener( MouseEvent.CLICK, onAddNodeRequestHandler );
			_removeNodeToolButton.addEventListener( MouseEvent.CLICK, onRemoveNodeRequestHandler );
			_addStarToolButton.addEventListener( MouseEvent.CLICK, onAddStarRequestHandler );
			_addBridgeToolButton.addEventListener( MouseEvent.CLICK, onAddBridgeRequestHandler );
		}

		protected function addCharListeners( ):void
		{
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'M', onImportRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'X', onExportRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'C', onDeviceViewRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'S', onJumpToStartRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'E', onJumpToEndRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'I', onZoomInRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'O', onZoomOutRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'L', onSelectNodeRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'A', onAddNodeRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'R', onRemoveNodeRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'T', onAddStarRequestHandler ) );
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'B', onAddBridgeRequestHandler ) );
		}
		
		protected function onMoveButtonMouseDownHandler( e:MouseEvent ):void
		{
			startDrag( false, new Rectangle( 0, 0, stage.stageWidth - width, stage.stageHeight - height ) );
		}
		
		protected function onStageMouseUpHandler( e:MouseEvent ):void
		{
			stopDrag( );
		}

		protected function onMoveButtonClickHandler( e:MouseEvent ):void
		{
			resetPosition( );
		}
		
		protected function resetPosition( ):void
		{
			x = BASE_POSITION.x;
			y = BASE_POSITION.y;
		}
		
		protected function onImportRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.IMPORT_REQUEST ) );
		}
		
		protected function onExportRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.EXPORT_REQUEST ) );
		}

		protected function onDeviceViewRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.CHANGE_CAMERA_VIEW_VISIBILITY ) );
		}

		protected function onJumpToStartRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.JUMP_VIEW_TO_START_REQUEST ) );
		}

		protected function onJumpToEndRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.JUMP_VIEW_TO_END_REQUEST ) );
		}

		protected function onSelectNodeRequestHandler( e:MouseEvent = null ):void
		{
			updateControllerButtonsView( _selectionToolButton );
			
			dispatchEvent( new MenuEvent( MenuEvent.SET_CONTROL_TO_SELECT ) );
		}
		
		protected function onAddNodeRequestHandler( e:MouseEvent = null ):void
		{
			updateControllerButtonsView( _addNodeToolButton );
			
			dispatchEvent( new MenuEvent( MenuEvent.SET_CONTROL_TO_ADD ) );
		}
		
		protected function onRemoveNodeRequestHandler( e:MouseEvent = null ):void
		{
			updateControllerButtonsView( _removeNodeToolButton );
			
			dispatchEvent( new MenuEvent( MenuEvent.SET_CONTROL_TO_REMOVE ) );
		}

		protected function onAddStarRequestHandler( e:MouseEvent = null ):void
		{
			updateControllerButtonsView( _addStarToolButton );
			
			dispatchEvent( new MenuEvent( MenuEvent.SET_CONTROL_TO_STAR ) );
		}

		protected function onAddBridgeRequestHandler( e:MouseEvent = null ):void
		{
			updateControllerButtonsView( _addBridgeToolButton );
			
			dispatchEvent( new MenuEvent( MenuEvent.SET_CONTROL_TO_BRIDGE ) );
		}
		
		protected function onZoomInRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.ZOOM_IN_REQUEST ) );
		}

		protected function onZoomOutRequestHandler( e:MouseEvent = null ):void
		{
			dispatchEvent( new MenuEvent( MenuEvent.ZOOM_OUT_REQUEST ) );
		}
		
		protected function updateControllerButtonsView( lastCalledControllerButton:SimpleButton ):void
		{
			_selectionToolButton.alpha = lastCalledControllerButton == _selectionToolButton ? .5 : 1;
			_addNodeToolButton.alpha = lastCalledControllerButton == _addNodeToolButton ? .5 : 1;
			_removeNodeToolButton.alpha = lastCalledControllerButton == _removeNodeToolButton ? .5 : 1;
			_addStarToolButton.alpha = lastCalledControllerButton == _addStarToolButton ? .5 : 1;
			_addBridgeToolButton.alpha = lastCalledControllerButton == _addBridgeToolButton ? .5 : 1;
		}
		
		override protected function stageResized( ):void
		{
			if ( this.x + this.width > this.stage.stageWidth )
			{
				this.x = this.stage.stageWidth - this.width;
				this.x = Math.max( 0, this.x );
			}
			
			if ( this.y + this.height > this.stage.stageHeight )
			{
				this.y = this.stage.stageHeight - this.height;
			}
		}
	}
}