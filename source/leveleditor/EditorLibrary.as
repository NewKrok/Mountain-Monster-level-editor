/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import leveleditor.assets.library.EditorLibraryAssets;
	import leveleditor.events.EditorLibraryEvent;

	import rv2.keyboard.KeyboardOperator;
	import rv2.keyboard.KeyboardSetting;

	public class EditorLibrary extends BaseUIComponent
	{
		private var BASE_POSITION:Point = new Point( 5, 5 );

		private var _editorLibraryAssets:EditorLibraryAssets;
		private var _editorLibraryView:EditorLibraryView;

		public var _moveButton:SimpleButton;
		public var _crateButton:SimpleButton;

		public var _back:DisplayObject;

		private var _lastSelectedLibraryType:String = '';

		public function EditorLibrary()
		{
			this._editorLibraryAssets = new EditorLibraryAssets();

			this._editorLibraryView = new EditorLibraryView();
			this.addChild( this._editorLibraryView );
		}

		override protected function inited( ):void
		{
			this._back = this['back'] as DisplayObject;

			this.processButtonsFromLibrary( );
			this.addButtonListeners( );
			this.addCharListeners( );

			this.stage.addEventListener( MouseEvent.MOUSE_UP, this.onStageMouseUpHandler );

			this.resetPosition( );
		}

		private function processButtonsFromLibrary( ):void
		{
			for ( var i:int; i < numChildren; i++ )
			{
				var selectedButton:SimpleButton = this.getChildAt( i ) as SimpleButton;

				if ( selectedButton && this.hasOwnProperty( '_' + selectedButton.name ) )
				{
					this['_' + selectedButton.name] = selectedButton;
				}
			}
		}

		private function addButtonListeners( ):void
		{
			this._moveButton.doubleClickEnabled = true;
			this._moveButton.addEventListener( MouseEvent.MOUSE_DOWN, this.onMoveButtonMouseDownHandler );
			this._moveButton.addEventListener( MouseEvent.DOUBLE_CLICK, this.onMoveButtonClickHandler );

			this._crateButton.addEventListener( MouseEvent.CLICK, this.openCrateLibrary );
		}

		private function addCharListeners( ):void
		{
			KeyboardOperator.addCharsListener( new KeyboardSetting( 'Y', this.openCrateLibrary ) );
		}

		private function onMoveButtonMouseDownHandler( e:MouseEvent ):void
		{
			var realSize:Rectangle = this.getRealSize();

			this.startDrag( false, new Rectangle( 0, 0, this.stage.stageWidth - realSize.width, this.stage.stageHeight - realSize.height ) );
		}

		private function onStageMouseUpHandler( e:MouseEvent ):void
		{
			this.stopDrag( );
		}

		private function onMoveButtonClickHandler( e:MouseEvent ):void
		{
			this.resetPosition( );
		}

		private function resetPosition( ):void
		{
			var realSize:Rectangle = this.getRealSize();

			this.x = this.stage.stageWidth - realSize.width - this.BASE_POSITION.x;
			this.y = this.BASE_POSITION.y;
		}

		private function setEditorLibraryViewPosition():void
		{
			this.removeChild( this._editorLibraryView );

			this._editorLibraryView.x = this._back.width - this._editorLibraryView.width;
			this._editorLibraryView.y = this._back.y + this._back.height + 2;

			this.addChildAt( this._editorLibraryView, 0 );
		}

		private function openCrateLibrary( e:MouseEvent = null ):void
		{
			this.openLibrary( EditorLibraryAssets.TYPE_CRATE );
		}

		private function openLibrary( type:String ):void
		{
			if ( this._lastSelectedLibraryType == type )
			{
				this.closeLibrary();
				return;
			}

			this.closeLibrary();

			this._lastSelectedLibraryType = type;

			this._editorLibraryView.buildView( this._editorLibraryAssets.getElementsByType( type ) );
			this._editorLibraryView.addEventListener( EditorLibraryEvent.ADD_ELEMENT_TO_WORLD_REQUEST, onAddelementToWorldRequestHandler )

			this.setEditorLibraryViewPosition();

			this.dispatchEvent( new EditorLibraryEvent( EditorLibraryEvent.OPEN_REQUEST ) );
		}

		private function onAddelementToWorldRequestHandler( e:EditorLibraryEvent ):void
		{
			this.dispatchEvent( e );
		}

		public function closeLibrary():void
		{
			this._lastSelectedLibraryType = '';

			this._editorLibraryView.clearView();
		}

		override protected function stageResized( ):void
		{
			var realSize:Rectangle = this.getRealSize();

			if ( Math.floor( this.x ) == Math.floor( this.lastStageSize.x - realSize.width - this.BASE_POSITION.x ) &&
				 Math.floor( this.y ) == this.BASE_POSITION.y
			)
			{
				this.resetPosition();
				return;
			}

			if ( this.x + realSize.width > this.stage.stageWidth )
			{
				this.x = this.stage.stageWidth - realSize.width;
				this.x = Math.max( 0, this.x );
			}

			if ( this.y + realSize.height > this.stage.stageHeight )
			{
				this.y = this.stage.stageHeight - realSize.height;
			}
		}

		private function getRealSize():Rectangle
		{
			return this._back.getBounds( this );
		}
	}
}