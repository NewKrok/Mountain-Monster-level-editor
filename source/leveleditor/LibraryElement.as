/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import leveleditor.assets.library.LibraryElementVO;
	import leveleditor.events.EditorLibraryEvent;

	public class LibraryElement extends Sprite
	{
		private var _view:LibraryElementPreview;

		private var _dragStartPosition:Point = new Point();

		public function LibraryElement( libraryElementVO:LibraryElementVO )
		{
			this.mouseChildren = false;

			this._view = new LibraryElementPreview( libraryElementVO );
			this._view.x = -_view.width / 2;
			this._view.y = -_view.height / 2;

			this.addChild( this._view );

			this.x = libraryElementVO.position.x;
			this.y = libraryElementVO.position.y;
			this.scaleX = libraryElementVO.scale;
		}

		public function activate():void
		{
			this.buttonMode = true;
			this.doubleClickEnabled = true;

			this.addEventListener( MouseEvent.CLICK, this.onClickHandler );
			this.addEventListener( MouseEvent.DOUBLE_CLICK, this.onDoubleClickHandler );
			this.addEventListener( MouseEvent.MOUSE_DOWN, this.onMouseDownHandler );
			this.stage.addEventListener( MouseEvent.MOUSE_UP, this.onMouseUpHandler );
		}

		public function deactivate():void
		{
			this.buttonMode = false;
			this.doubleClickEnabled = false;

			this.removeEventListener( MouseEvent.CLICK, this.onClickHandler );
			this.removeEventListener( MouseEvent.DOUBLE_CLICK, this.onDoubleClickHandler );
			this.removeEventListener( MouseEvent.MOUSE_DOWN, this.onMouseDownHandler );
			this.stage.removeEventListener( MouseEvent.MOUSE_UP, this.onMouseUpHandler );
		}

		private function onClickHandler( e:MouseEvent ):void
		{
			if( Math.abs( this._dragStartPosition.x - this.x ) < 5 && Math.abs( this._dragStartPosition.y - this.y ) < 5 )
			{
				this.scaleX = -this.scaleX;
			}
		}

		private function onDoubleClickHandler( e:MouseEvent ):void
		{
			this.dispatchEvent( new EditorLibraryEvent( EditorLibraryEvent.REMOVE_ELEMENT_FROM_WORLD_REQUEST ) );
		}

		private function onMouseDownHandler( e:MouseEvent ):void
		{
			this.startDrag();
			this._dragStartPosition.setTo( x, y );
		}

		private function onMouseUpHandler( e:MouseEvent ):void
		{
			this.stopDrag();

			this.x = BaseUIComponent.snapToGrid( this.x, 5 );
			this.y = BaseUIComponent.snapToGrid( this.y, 5 );
		}

		public function getLibraryElementVO():LibraryElementVO
		{
			var libraryElementVO:LibraryElementVO = this._view.getLibraryElementVO().clone();
			libraryElementVO.position.setTo( this.x, this.y );
			libraryElementVO.scale = this.scaleX;

			return libraryElementVO;
		}
	}
}