/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor
{
	import leveleditor.events.*;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import leveleditor.LibraryElementPreview;

	import leveleditor.assets.library.LibraryElementVO;

	public class EditorLibraryView extends Sprite
	{
		private const ELEMENT_PER_ROW:uint = 3;
		private const ELEMENT_GAP:uint = 10;

		private var _back:DisplayObject;

		private var _elementContainer:Sprite;
		private var _rows:Vector.<DisplayObjectContainer> = new <DisplayObjectContainer>[];
		private var _sampleElement:LibraryElementPreview;

		public function EditorLibraryView()
		{
			this._back = new EditorLibraryBack as DisplayObject;

			this._elementContainer = new Sprite();
			this.addChild( this._elementContainer );
			this._elementContainer.y = 5;
		}

		public function buildView( libraryElements:Vector.<LibraryElementVO> ):void
		{
			var length:int = libraryElements.length;
			var col:int = 0;
			var row:int = 0;

			for( var i:int = 0; i < length; i++ )
			{
				if( col == 0 )
				{
					this._rows.push( new Sprite() );
					this._elementContainer.addChild( this._rows[row] );
				}

				var element:LibraryElementPreview = new LibraryElementPreview( libraryElements[i] );
				element.buttonMode = true;
				element.addEventListener( MouseEvent.MOUSE_DOWN, onElementDownHandler );

				element.x = this._rows[row].width + ( col > 0 ? this.ELEMENT_GAP : 0 );

				if( row > 0 )
				{
					this._rows[row].y = this._rows[row - 1].height + this.ELEMENT_GAP;
				}

				this._rows[row].addChild( element );

				col++;
				if( col >= ELEMENT_PER_ROW )
				{
					col = 0;
					row++;
				}
			}

			this.addChildAt( this._back, 0 );

			this._back.width = this._elementContainer.width + 10;
			this._back.height = this._elementContainer.height + 10;

			length = this._rows.length;
			for( i = 0; i < length; i++ )
			{
				this._rows[i].x = this._back.width / 2 - this._rows[i].width / 2;
				this.setYPositionInRow( this._rows[i] );
			}

			this.stage.addEventListener( MouseEvent.MOUSE_UP, onElementUpHandler );
		}

		private function setYPositionInRow( row:DisplayObjectContainer ):void
		{
			var length:int = row.numChildren;

			for( var i:int = 0; i < length; i++ )
			{
				var child:DisplayObject = row.getChildAt( i );
				child.y = row.height / 2 - child.height / 2;
			}
		}

		private function onElementDownHandler( e:MouseEvent ):void
		{
			this.disposeSampleElement();

			this._sampleElement = new LibraryElementPreview( ( e.currentTarget as LibraryElementPreview ).getLibraryElementVO() );
			this.stage.addChild( this._sampleElement );

			var globalCoordinate:Point = e.currentTarget.parent.localToGlobal( new Point( e.currentTarget.x, e.currentTarget.y ) );

			this._sampleElement.x = globalCoordinate.x;
			this._sampleElement.y = globalCoordinate.y;
			this._sampleElement.startDrag( false, new Rectangle( 0, 0, this.stage.stageWidth - this._sampleElement.width, this.stage.stageHeight - this._sampleElement.height ) );
		}

		private function onElementUpHandler( e:MouseEvent ):void
		{
			if( this._sampleElement )
			{
				var elementVO:LibraryElementVO = this._sampleElement.getLibraryElementVO().clone();

				var globalCoordinate:Point = e.target.parent.localToGlobal( new Point( e.target.x + e.target.width / 2, e.target.y + e.target.height / 2 ) );

				globalCoordinate.x = BaseUIComponent.snapToGrid( globalCoordinate.x, 5 );
				globalCoordinate.y = BaseUIComponent.snapToGrid( globalCoordinate.y, 5 );

				elementVO.position = globalCoordinate;

				this.dispatchEvent( new EditorLibraryEvent( EditorLibraryEvent.ADD_ELEMENT_TO_WORLD_REQUEST, elementVO ) );

				this.disposeSampleElement();
			}
		}

		private function disposeSampleElement():void
		{
			if( this._sampleElement )
			{
				this._sampleElement.stopDrag();
				this.stage.removeChild( this._sampleElement );
				this._sampleElement = null;
			}
		}

		public function clearView():void
		{
			if( this._back.parent )
			{
				this.removeChild( this._back );

				this.clearRows();
			}
		}

		private function clearRows():void
		{
			var length:int = this._rows.length;

			for( var i:int = 0; i < length; i++ )
			{
				this.clearRow( this._rows[i] );
				this._elementContainer.removeChild( this._rows[i] );
				this._rows[i] = null;
			}

			this._rows.length = 0;
		}

		private function clearRow( row:DisplayObjectContainer ):void
		{
			while( row.numChildren > 0 )
			{
				var element:LibraryElementPreview = row.getChildAt( 0 ) as LibraryElementPreview;
				element.removeEventListener( MouseEvent.MOUSE_DOWN, onElementDownHandler );

				row.removeChildAt( 0 );
			}

			this.stage.addEventListener( MouseEvent.MOUSE_UP, onElementUpHandler );
		}
	}
}