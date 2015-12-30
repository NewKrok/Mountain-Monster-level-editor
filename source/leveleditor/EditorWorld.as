package leveleditor
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import leveleditor.assets.library.LibraryElementVO;

	import leveleditor.controller.BridgeToolController;
	import leveleditor.controller.StarToolController;
	import leveleditor.data.LevelDataVO;
	import leveleditor.events.EditorLibraryEvent;
	import leveleditor.events.EditorWorldEvent;

	public class EditorWorld extends BaseUIComponent
	{
		protected const DEFAULT_WORLD_SIZE:Point = new Point( 7000, 800 );

		public static const CONTROL_TYPE_SELECT:String = 'EditorWorld.CONTROL_TYPE_SELECT';
		public static const CONTROL_TYPE_ADD_NODE:String = 'EditorWorld.CONTROL_TYPE_ADD_NODE';
		public static const CONTROL_TYPE_REMOVE_NODE:String = 'EditorWorld.CONTROL_TYPE_REMOVE_NODE';
		public static const CONTROL_TYPE_ADD_STAR:String = 'EditorWorld.CONTROL_TYPE_ADD_STAR';
		public static const CONTROL_TYPE_ADD_BRIDGE:String = 'EditorWorld.CONTROL_TYPE_ADD_BRIDGE';

		protected var _finishMarker:FinishMarker;
		protected var _startMarker:StartMarker;

		protected var _background:Sprite;
		protected var _markerContainer:Sprite;
		protected var _starContainer:Sprite;
		protected var _libraryElementContainer:Sprite;
		protected var _bridgeContainer:Sprite;
		protected var _lineContainer:Sprite;
		protected var _graphicsMarkContainer:Sprite;
		protected var _nodeContainer:Sprite;

		protected var _nodeViews:Vector.<NodeView> = new Vector.<NodeView>;
		protected var _sizeMarkers:Vector.<TextField> = new Vector.<TextField>;
		protected var _libraryElements:Vector.<LibraryElement> = new Vector.<LibraryElement>;

		protected var _controlType:String = '';
		protected var _dragStartPoint:Point = new Point;
		protected var _dragStartMousePoint:Point = new Point;

		protected var _nearestNode:NodeView;
		protected var _nearestNodeIndex:int = 0;
		protected var _nearestNodeDistance:Number = 0;

		protected var _draggedNode:NodeView;
		protected var _blockWorldDrag:Boolean = false;

		protected var _starToolController:StarToolController;
		protected var _bridgeToolController:BridgeToolController;

		public function EditorWorld()
		{
		}

		override protected function inited():void
		{
			addChild( _background = new Sprite );
			addChild( _markerContainer = new Sprite );
			addChild( _starContainer = new Sprite );
			addChild( _libraryElementContainer = new Sprite );
			addChild( _bridgeContainer = new Sprite );
			addChild( _lineContainer = new Sprite );
			addChild( _graphicsMarkContainer = new Sprite );
			addChild( _nodeContainer = new Sprite );
			addChild( _finishMarker = new FinishMarker( this ) );
			addChild( _startMarker = new StartMarker( this ) );

			draw();

			x = stage.stageWidth / 2 - width / 2;
			y = stage.stageHeight / 2 - height / 2;

			addEventListener( MouseEvent.MOUSE_DOWN, onMouseDownHandler );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUpHandler );

			initControllers();
		}

		protected function initControllers():void
		{
			_starToolController = new StarToolController( this, _starContainer );
			_bridgeToolController = new BridgeToolController( this, _bridgeContainer );
		}

		protected function onMouseDownHandler( e:MouseEvent ):void
		{
			if( _blockWorldDrag || e.target == _finishMarker || e.target == _startMarker || e.target is LibraryElement )
			{
				return;
			}

			addEventListener( MouseEvent.MOUSE_MOVE, onMouseMoveHandler );

			_dragStartPoint.setTo( x, y );
			_dragStartMousePoint.setTo( mouseX, mouseY );

		}

		protected function onMouseMoveHandler( event:MouseEvent ):void
		{
			if( Point.distance( _dragStartMousePoint, new Point( mouseX, mouseY ) ) > 10 && !_blockWorldDrag )
			{
				startDrag( false );
			}
		}

		protected function onStageMouseUpHandler( e:MouseEvent ):void
		{
			removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMoveHandler );

			stopDrag();
			normalizePositions();
		}

		protected function draw():void
		{
			removeSizeMarkers();
			drawLines();

			_background.graphics.clear();

			_background.graphics.beginFill( 0xFFFFFF, .2 );
			_background.graphics.drawRect( 0, 0, DEFAULT_WORLD_SIZE.x, DEFAULT_WORLD_SIZE.y );
			_background.graphics.endFill();

			generateSizeMarkers();
		}

		protected function removeSizeMarkers():void
		{
			for( var i:int = 0; i < _sizeMarkers.length; i++ )
			{
				_markerContainer.removeChild( _sizeMarkers[ i ] );
				_sizeMarkers[ i ] = null;
			}
			_sizeMarkers.length = 0;
		}

		protected function drawLines():void
		{
			resetLines();

			if( _nodeViews.length > 0 )
			{
				for( var i:int = 0; i < _nodeViews.length; i++ )
				{
					if( i == 0 )
					{
						_lineContainer.graphics.moveTo( _nodeViews[ i ].x, _nodeViews[ i ].y );
					}
					else
					{
						_lineContainer.graphics.lineTo( normalizePixelCoordinate( _nodeViews[ i ].x ), normalizePixelCoordinate( _nodeViews[ i ].y ) );
					}
				}

				if( _controlType == CONTROL_TYPE_ADD_NODE )
				{
					_lineContainer.graphics.lineTo( normalizePixelCoordinate( mouseX ), normalizePixelCoordinate( mouseY ) );
				}
			}
		}

		protected function drawSelectedNodeMarker():void
		{
			_graphicsMarkContainer.graphics.clear();
			if( _controlType == CONTROL_TYPE_SELECT && _nearestNode && _nearestNodeDistance < 30 )
			{
				_graphicsMarkContainer.graphics.beginFill( 0xFFFFFF, 1 );
				_graphicsMarkContainer.graphics.drawCircle( normalizePixelCoordinate( _nearestNode.x ), normalizePixelCoordinate( _nearestNode.y ), 10 );
				_graphicsMarkContainer.graphics.drawCircle( normalizePixelCoordinate( _nearestNode.x ), normalizePixelCoordinate( _nearestNode.y ), 7 );
			}
		}

		protected function drawNewNodePositionMarker():void
		{
			_graphicsMarkContainer.graphics.clear();

			if( _controlType == CONTROL_TYPE_ADD_NODE )
			{
				_graphicsMarkContainer.graphics.beginFill( 0x000000, 1 );
				_graphicsMarkContainer.graphics.drawCircle( normalizePixelCoordinate( mouseX ), normalizePixelCoordinate( mouseY ), 10 );
				_graphicsMarkContainer.graphics.drawCircle( normalizePixelCoordinate( mouseX ), normalizePixelCoordinate( mouseY ), 7 );
			}
		}

		protected function drawRemovableNodeMarker():void
		{
			_graphicsMarkContainer.graphics.clear();

			if( _controlType == CONTROL_TYPE_REMOVE_NODE && _nearestNode && _nearestNodeDistance < 30 )
			{
				_graphicsMarkContainer.graphics.beginFill( 0xFF0000, 1 );
				_graphicsMarkContainer.graphics.drawCircle( normalizePixelCoordinate( _nearestNode.x ), normalizePixelCoordinate( _nearestNode.y ), 10 );
				_graphicsMarkContainer.graphics.drawCircle( normalizePixelCoordinate( _nearestNode.x ), normalizePixelCoordinate( _nearestNode.y ), 7 );
			}
		}

		protected function resetLines():void
		{
			_lineContainer.graphics.clear();
			_lineContainer.graphics.lineStyle( 2, 0x000000, 1 );
		}

		protected function generateSizeMarkers():void
		{
			var markerCount:int = Math.floor( _background.width / 200 );

			for( var i:int = 0; i < markerCount; i++ )
			{
				addSizeMarker( i * 200, 0 );
				addSizeMarker( i * 200, _background.height - _sizeMarkers[ 0 ].height );
			}
		}

		protected function addSizeMarker( xPosition:uint, yPosition:uint ):void
		{
			var marker:TextField = createMarkerText( xPosition );
			marker.y = yPosition;

			_markerContainer.addChild( marker );
			_sizeMarkers.push( marker );
		}

		protected function createMarkerText( xPosition:uint ):TextField
		{
			var marker:TextField = new TextField();
			marker.text = '| ' + String( xPosition );
			marker.autoSize = 'left';
			marker.alpha = .3;
			marker.x = xPosition;

			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xFFFFFF;
			textFormat.size = 10;
			textFormat.font = 'verdana';

			marker.setTextFormat( textFormat );

			return marker
		}

		public function jumpToStart( viewPort:Rectangle ):void
		{
			x = viewPort.x;
			y = viewPort.y;

			normalizePositions();
		}

		public function jumpToEnd( viewPort:Rectangle ):void
		{
			x = viewPort.x + viewPort.width - width;
			y = viewPort.y;

			normalizePositions();
		}

		protected function normalizePositions():void
		{
			x = normalizePixelCoordinateWithScale( x );
			y = normalizePixelCoordinateWithScale( y );
		}

		public function zoomIn():void
		{
			this.scaleX += .1;

			this.scaleX = Math.min( this.scaleX, 2 );

			this.scaleY = this.scaleX;

			this.normalizePositions();

			this.dispatchEvent( new EditorWorldEvent( EditorWorldEvent.ON_VIEW_RESIZE, this.scaleX ) );
		}

		public function zoomOut():void
		{
			this.scaleX -= .1;

			this.scaleX = Math.max( this.scaleX, .2 );

			this.scaleY = this.scaleX;

			this.normalizePositions();

			this.dispatchEvent( new EditorWorldEvent( EditorWorldEvent.ON_VIEW_RESIZE, this.scaleX ) );
		}

		public function setControl( type:String ):void
		{
			_controlType = type;

			_starToolController.deactivate();
			_bridgeToolController.deactivate();
			this.deactivateLibraryElements();

			removeControllerListeners();

			drawLines();
			drawSelectedNodeMarker();
			drawNewNodePositionMarker();
			drawRemovableNodeMarker();

			_blockWorldDrag = false;

			switch( _controlType )
			{
				case CONTROL_TYPE_SELECT:
					setControlToSelectNode();
					this.activateLibraryElements();
					break;
				case CONTROL_TYPE_ADD_NODE:
					setControlToAddNode();
					break;
				case CONTROL_TYPE_REMOVE_NODE:
					setControlToRemoveNode();
					break;
				case CONTROL_TYPE_ADD_STAR:
					_starToolController.activate();
					break;
				case CONTROL_TYPE_ADD_BRIDGE:
					_bridgeToolController.activate();
					break;
			}
		}

		protected function removeControllerListeners():void
		{
			removeEventListener( MouseEvent.MOUSE_DOWN, onNodeMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUpHandlerForNode );
			removeEventListener( MouseEvent.MOUSE_MOVE, selectNearestNodeToSelect );

			removeEventListener( MouseEvent.CLICK, addNodeHandler );
			removeEventListener( MouseEvent.MOUSE_MOVE, updateLinesHandler );

			removeEventListener( MouseEvent.CLICK, removeNodeHandler );
			removeEventListener( MouseEvent.MOUSE_MOVE, selectNearestNodeToRemove );
		}

		public function addLibraryElement( elementVO:LibraryElementVO ):void
		{
			elementVO.position.x -= this.x;
			elementVO.position.y -= this.y;

			var libraryElement:LibraryElement = new LibraryElement( elementVO );
			libraryElement.addEventListener( EditorLibraryEvent.REMOVE_ELEMENT_FROM_WORLD_REQUEST, this.onRemoveLibraryElementRequestHandler );

			this._libraryElements.push( libraryElement );
			this._libraryElementContainer.addChild( libraryElement );

			libraryElement.activate();
		}

		private function onRemoveLibraryElementRequestHandler( e:EditorLibraryEvent ):void
		{
			var length:int = this._libraryElements.length;

			for( var i:int = 0; i < length; i++ )
			{
				if( this._libraryElements[ i ] == e.currentTarget )
				{
					this._libraryElements[ i ].removeEventListener( EditorLibraryEvent.REMOVE_ELEMENT_FROM_WORLD_REQUEST, this.onRemoveLibraryElementRequestHandler );
					this._libraryElements[ i ].deactivate();
					this._libraryElementContainer.removeChild( this._libraryElements[ i ] );
					this._libraryElements[ i ] = null;
					this._libraryElements.splice( i, 1 );
					break;
				}
			}
		}

		private function activateLibraryElements():void
		{
			var length:int = this._libraryElements.length;

			for( var i:int = 0; i < length; i++ )
			{
				this._libraryElements[ i ].activate();
			}
		}

		private function deactivateLibraryElements():void
		{
			var length:int = this._libraryElements.length;

			for( var i:int = 0; i < length; i++ )
			{
				this._libraryElements[ i ].deactivate();
			}
		}

		protected function setControlToSelectNode():void
		{
			addEventListener( MouseEvent.MOUSE_DOWN, onNodeMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUpHandlerForNode );
			addEventListener( MouseEvent.MOUSE_MOVE, selectNearestNodeToSelect );
		}

		protected function onNodeMouseDown( e:MouseEvent ):void
		{
			if( _nearestNode && _nearestNodeDistance < 30 )
			{
				_nearestNode.startDrag( true );
				_draggedNode = _nearestNode;
			}
		}

		protected function onStageMouseUpHandlerForNode( e:MouseEvent ):void
		{
			if( _draggedNode )
			{
				_draggedNode.stopDrag();

				_draggedNode.x = normalizePixelCoordinate( _draggedNode.x );
				_draggedNode.y = normalizePixelCoordinate( _draggedNode.y );
				drawLines();
			}
		}

		protected function selectNearestNodeToSelect( e:MouseEvent ):void
		{
			setNearestNodeFromMouse();
			drawSelectedNodeMarker();

			if( _nearestNode && _nearestNodeDistance < 30 )
			{
				_blockWorldDrag = true;
			}
			else
			{
				_blockWorldDrag = false;
			}

			drawLines();
		}

		protected function setControlToAddNode():void
		{
			addEventListener( MouseEvent.CLICK, addNodeHandler );
			addEventListener( MouseEvent.MOUSE_MOVE, updateLinesHandler );
		}

		protected function addNodeHandler( e:MouseEvent ):void
		{
			if( !isWorldDragged() )
			{
				addNodeTo( mouseX, mouseY );
			}
		}

		protected function addNodeTo( x:Number, y:Number ):void
		{
			var nodeView:NodeView = new NodeView();
			nodeView.x = normalizePixelCoordinate( x );
			nodeView.y = normalizePixelCoordinate( y );

			_nodeContainer.addChild( nodeView );
			_nodeViews.push( nodeView );

			drawLines();
		}

		protected function updateLinesHandler( e:MouseEvent ):void
		{
			drawLines();
			drawNewNodePositionMarker();
		}

		protected function setControlToRemoveNode():void
		{
			if( _nodeViews.length > 0 )
			{
				addEventListener( MouseEvent.CLICK, removeNodeHandler );
				addEventListener( MouseEvent.MOUSE_MOVE, selectNearestNodeToRemove );
			}
		}

		protected function removeNodeHandler( e:MouseEvent ):void
		{
			if( _nearestNodeDistance < 30 && !isWorldDragged() )
			{
				_nodeContainer.removeChild( _nearestNode );

				_nodeViews.splice( _nearestNodeIndex, 1 );

				selectNearestNodeToRemove( e );
				drawLines();
				drawRemovableNodeMarker();
			}
		}

		protected function selectNearestNodeToRemove( e:MouseEvent ):void
		{
			setNearestNodeFromMouse();
			drawRemovableNodeMarker();
		}

		protected function setNearestNodeFromMouse():void
		{
			if( _nodeViews.length > 0 )
			{
				_nearestNode = _nodeViews[ 0 ];
				_nearestNodeIndex = 0;
				_nearestNodeDistance = Point.distance( new Point( _nearestNode.x, _nearestNode.y ), new Point( mouseX, mouseY ) );

				for( var i:int = 0; i < _nodeViews.length; i++ )
				{
					var distance:Number = Point.distance( new Point( _nodeViews[ i ].x, _nodeViews[ i ].y ), new Point( mouseX, mouseY ) );
					if( distance < _nearestNodeDistance )
					{
						_nearestNodeIndex = i;
						_nearestNode = _nodeViews[ i ];
						_nearestNodeDistance = distance;
					}
				}
			}
			else
			{
				_nearestNodeIndex = 0;
				_nearestNode = null;
				_nearestNodeDistance = 0;
			}
		}

		public function loadLevel( levelData:LevelDataVO ):void
		{
			for( var i:int = 0; i < levelData.groundPoints.length; i++ )
			{
				addNodeTo( levelData.groundPoints[ i ].x, levelData.groundPoints[ i ].y );
			}

			_starToolController.loadStars( levelData.starPoints );
			_bridgeToolController.loadBridges( levelData.bridgePoints );

			if( levelData.startPoint && levelData.startPoint.x )
			{
				_startMarker.x = levelData.startPoint.x;
				_startMarker.y = levelData.startPoint.y;
			}

			if( levelData.finishPoint && levelData.finishPoint.x )
			{
				_finishMarker.x = levelData.finishPoint.x;
				_finishMarker.y = levelData.finishPoint.y;
			}

			if( levelData.libraryElements )
			{
				this.loadLibraryElements( levelData.libraryElements );
			}
		}

		private function loadLibraryElements( datas:Array ):void
		{
			var length:int = datas.length;

			for( var i:int = 0; i < length; i++ )
			{
				var libraryElementVO:LibraryElementVO = new LibraryElementVO( 'import', datas[i].className );
				libraryElementVO.scale = datas[i].scale;
				libraryElementVO.position = new Point( datas[i].x + this.x, datas[i].y + this.y );

				this.addLibraryElement( libraryElementVO );
			}
		}

		public function getLevelData():LevelDataVO
		{
			var levelData:LevelDataVO = new LevelDataVO();

			for( var i:int = 0; i < _nodeViews.length; i++ )
			{
				levelData.groundPoints.push( {x: _nodeViews[ i ].x, y: _nodeViews[ i ].y} )
			}

			levelData.starPoints = _starToolController.getStarPoints();
			levelData.bridgePoints = _bridgeToolController.getBridgePoints();
			levelData.startPoint = {x: _startMarker.x, y: _startMarker.y};
			levelData.finishPoint = {x: _finishMarker.x, y: _finishMarker.y};
			levelData.libraryElements = this.createLibraryElementExportData();

			return levelData;
		}

		private function createLibraryElementExportData():Array
		{
			var result:Array = [];

			var length:int = this._libraryElements.length;

			for( var i:int = 0; i < length; i++ )
			{
				var libraryElementVO:LibraryElementVO = this._libraryElements[i].getLibraryElementVO();

				result.push( { className: libraryElementVO.className, scale: libraryElementVO.scale, x: libraryElementVO.position.x, y: libraryElementVO.position.y } );
			}

			return result;
		}

		public function isWorldDragged():Boolean
		{
			return Point.distance( _dragStartPoint, new Point( x, y ) ) != 0;
		}

		public function set blockWorldDrag( value:Boolean ):void
		{
			_blockWorldDrag = value;
		}

		override public function get width():Number
		{
			return _background.width;
		}

		override public function get height():Number
		{
			return _background.height;
		}

		private function normalizePixelCoordinateWithScale( value:Number ):Number
		{
			return snapToGrid( value, PIXEL_SNAP_VALUE * this.scaleX );
		}

		private function normalizePixelCoordinate( value:Number ):Number
		{
			return snapToGrid( value );
		}
	}
}