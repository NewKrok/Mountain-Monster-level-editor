package leveleditor.controller
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	import leveleditor.BaseUIComponent;
	import leveleditor.EditorWorld;
	
	import rv2.geom.ColorOperator;

	public class BridgeToolController
	{
		protected const PIXEL_SNAP_VALUE:Number = 10;
		
		protected var grayFilter:ColorMatrixFilter = ColorOperator.adjustSaturation( -1 );
		
		protected var _bridgeDatas:Vector.<Object> = new Vector.<Object>;
		protected var _bridgeViews:Vector.<Bridge> = new Vector.<Bridge>;
		protected var _bridgeHelperViews:Vector.<Vector.<Bridge>> = new Vector.<Vector.<Bridge>>;
		
		protected var _sampleBridge:Bridge;
		protected var _bridgeContainer:DisplayObjectContainer;
		
		protected var _draggedBridge:Bridge;
		
		protected var _nearestBridge:Bridge;
		protected var _nearestBridgeIndex:int = 0;
		protected var _nearestBridgeDistance:Number = 0;
		
		protected var _editorWorld:EditorWorld;
		
		protected var _isBuildingInProgress:Boolean = false;

		protected var _isActivated:Boolean = false;
		
		public function BridgeToolController( editorWorld:EditorWorld, bridgeContainer:DisplayObjectContainer )
		{
			this._editorWorld = editorWorld;
			_bridgeContainer = bridgeContainer;
			
			editorWorld.addChild( _sampleBridge = new Bridge( ) );
			_sampleBridge.visible = false;
		}
		
		public function activate( ):void
		{
			_isActivated = true;
			
			_sampleBridge.visible = true;
			_sampleBridge.mouseChildren = false;
			_sampleBridge.mouseEnabled = false;
			_sampleBridge.alpha = .3;
			
			_editorWorld.doubleClickEnabled = true;
			_editorWorld.addEventListener( MouseEvent.CLICK, addBridgeRequest );
			_editorWorld.addEventListener( MouseEvent.MOUSE_MOVE, onAddBridgeMouseMove );
			_editorWorld.addEventListener( MouseEvent.MOUSE_DOWN, onBridgeMouseDown );
			_editorWorld.stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUpHandler );
		}
		
		public function deactivate( ):void
		{
			_isActivated = false;
			
			_sampleBridge.visible = false;
			
			_editorWorld.doubleClickEnabled = false;
			_editorWorld.removeEventListener( MouseEvent.CLICK, addBridgeRequest );
			_editorWorld.removeEventListener( MouseEvent.MOUSE_MOVE, onAddBridgeMouseMove );
			_editorWorld.removeEventListener( MouseEvent.MOUSE_DOWN, onBridgeMouseDown );
			_editorWorld.stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUpHandler );
		}
		
		protected function onAddBridgeMouseMove( e:MouseEvent ):void
		{
			_sampleBridge.x = snapToGrid( _editorWorld.mouseX );
			_sampleBridge.y = snapToGrid( _editorWorld.mouseY );
			
			setNearestbridgeFromMouse( );
			
			if ( _draggedBridge )
			{
				drawDraggedBridgeHelpers( );
			}
		}

		protected function onBridgeMouseDown( e:MouseEvent ):void
		{
			if ( _nearestBridge && _nearestBridgeDistance < 20 )
			{
				_editorWorld.blockWorldDrag = true;
				
				_nearestBridge.startDrag( true );
				_draggedBridge = _nearestBridge;
			}
		}

		protected function onStageMouseUpHandler( e:MouseEvent ):void
		{
			if ( _draggedBridge )
			{
				_draggedBridge.stopDrag( );
				
				_draggedBridge.x = snapToGrid( _draggedBridge.x );
				_draggedBridge.y = snapToGrid( _draggedBridge.y );
				
				drawDraggedBridgeHelpers( );
				
				_draggedBridge = null;
				
				_editorWorld.blockWorldDrag = false;
			}
		}
		
		protected function drawAllBridge( ):void
		{
			for ( var i:int = 0; i < _bridgeDatas.length; i++ )
			{
				drawBridgeHelpers( i );
			}
		}
		
		protected function drawDraggedBridgeHelpers( ):void
		{
			for ( var i:int = 0; i < _bridgeDatas.length; i++ )
			{
				if ( _draggedBridge == _bridgeDatas[i].bridgeA || _draggedBridge == _bridgeDatas[i].bridgeB )
				{
					drawBridgeHelpers( i );
					return;
				}
			}
		}
		
		protected function drawBridgeHelpers( bridgeIndex:int ):void
		{
			removeHelperBridges( bridgeIndex );
			
			var bridgeAngle:Number = Math.atan2( _bridgeDatas[bridgeIndex].bridgeB.y - _bridgeDatas[bridgeIndex].bridgeA.y, _bridgeDatas[bridgeIndex].bridgeB.x - _bridgeDatas[bridgeIndex].bridgeA.x );
			var bridgeElementWidth:int = 30;
			var bridgeDistance:Number = Point.distance( 
								new Point( _bridgeDatas[bridgeIndex].bridgeA.x, _bridgeDatas[bridgeIndex].bridgeA.y ),
								new Point( _bridgeDatas[bridgeIndex].bridgeB.x, _bridgeDatas[bridgeIndex].bridgeB.y )
							);
			var pieces:Number = bridgeDistance / bridgeElementWidth;
			
			if ( bridgeDistance % bridgeElementWidth == 0 )
				pieces++;
			
			for ( var j:int = 0; j < pieces; j++ )
			{
				if ( j == 0 || j == pieces - 1 )
				{
					_bridgeDatas[bridgeIndex].bridgeB.rotation = bridgeAngle * ( 180 / Math.PI );
					_bridgeDatas[bridgeIndex].bridgeA.rotation = bridgeAngle * ( 180 / Math.PI );
				}
				else
				{
					var bridge:Bridge = new Bridge( );
					bridge.alpha = .5;
					
					_bridgeHelperViews[bridgeIndex].push( bridge );
					_editorWorld.addChildAt( bridge, 0 );
					
					bridge.x = _bridgeDatas[bridgeIndex].bridgeA.x + j * bridgeElementWidth * Math.cos( bridgeAngle );
					bridge.y = _bridgeDatas[bridgeIndex].bridgeA.y + j * bridgeElementWidth * Math.sin( bridgeAngle );
					bridge.rotation = bridgeAngle * ( 180 / Math.PI );
				}
			}
		}
		
		protected function removeHelperBridges( bridgeDataIndex:int ):void
		{
			for ( var i:int = 0; i < _bridgeHelperViews[bridgeDataIndex].length; i++ )
			{
				_editorWorld.removeChild( _bridgeHelperViews[bridgeDataIndex][i] );
				_bridgeHelperViews[bridgeDataIndex][i] = null;
			}
			
			_bridgeHelperViews[bridgeDataIndex] = new Vector.<Bridge>;
		}
		
		protected function addBridgeRequest( e:MouseEvent ):void
		{
			if ( !_editorWorld.isWorldDragged( ) )
			{
				if ( _nearestBridge && _nearestBridge.parent && _nearestBridgeDistance < 20 )
				{
					return;
				}
				else
				{
					addBridge( _editorWorld.mouseX, _editorWorld.mouseY, _editorWorld.mouseX + 120, _editorWorld.mouseY );
					_isBuildingInProgress = true;
				}
				
				drawBridgeHelpers( _bridgeDatas.length - 1 );
			}
		}
		
		protected function removeBridgeRequest( e:MouseEvent ):void
		{
			if ( _nearestBridge && _nearestBridge.parent && _nearestBridgeDistance < 20 )
			{
				removeBridge( _nearestBridge );
			}
		}
		
		protected function addBridge( aX:Number, aY:Number, bX:Number, bY:Number ):void
		{
			var bridgeA:Bridge = new Bridge( );
			bridgeA.buttonMode = true;
			bridgeA.x = snapToGrid( aX );
			bridgeA.y = snapToGrid( aY );
			_bridgeContainer.addChild( bridgeA );
			_bridgeViews.push( bridgeA );
			
			var bridgeB:Bridge = new Bridge( );
			bridgeB.buttonMode = true;
			bridgeB.x = snapToGrid( bX );
			bridgeB.y = snapToGrid( bY );
			_bridgeContainer.addChild( bridgeB );
			_bridgeViews.push( bridgeB );
			
			_bridgeDatas.push( { bridgeA: bridgeA, bridgeB: bridgeB } );
			_bridgeHelperViews.push( new Vector.<Bridge> );
			
			if ( _isActivated )
			{
				setNearestbridgeFromMouse( );
			}
		}
		
		protected function removeBridge( bridge:Bridge ):void
		{
			for ( var i:int = 0; i < _bridgeDatas.length; i++ )
			{
				if ( bridge == _bridgeDatas[i].bridgeA || bridge == _bridgeDatas[i].bridgeB )
				{
					for ( var j:int = 0; j < _bridgeViews.length; j++ )
					{
						if ( _bridgeViews[j] == _bridgeDatas[i].bridgeA )
						{
							_bridgeViews.splice( j, 1 );
						}
						
						if ( _bridgeViews[j] == _bridgeDatas[i].bridgeB )
						{
							_bridgeViews.splice( j, 1 );
						}
					}
					
					_bridgeContainer.removeChild( _bridgeDatas[i].bridgeA );
					_bridgeDatas[i].bridgeA = null;
					
					_bridgeContainer.removeChild( _bridgeDatas[i].bridgeB );
					_bridgeDatas[i].bridgeB = null;
					
					_bridgeDatas.splice( i, 1 );
					
					removeHelperBridges( i );
					_bridgeHelperViews.splice( i, 1 );
				}
			}
		}
		
		protected function setNearestbridgeFromMouse( ):void
		{
			if ( _bridgeViews.length > 0 )
			{
				_nearestBridge = _bridgeViews[0];
				_nearestBridgeIndex = 0;
				_nearestBridgeDistance = Point.distance( new Point( _nearestBridge.x, _nearestBridge.y ), new Point( _editorWorld.mouseX, _editorWorld.mouseY ) );
				
				for ( var i:int = 0; i < _bridgeViews.length; i++ )
				{
					_bridgeViews[i].filters = [];
					_bridgeViews[i].doubleClickEnabled = true;
					_bridgeViews[i].addEventListener( MouseEvent.DOUBLE_CLICK, removeBridgeRequest );
					
					var distance:Number = Point.distance( new Point( _bridgeViews[i].x, _bridgeViews[i].y ), new Point( _editorWorld.mouseX, _editorWorld.mouseY ) );
					if ( distance < _nearestBridgeDistance )
					{
						_nearestBridgeIndex = i;
						_nearestBridge = _bridgeViews[i];
						_nearestBridgeDistance = distance;
					}
				}
				
				if ( _nearestBridgeDistance < 30 )
				{
					_sampleBridge.visible = false;
					_nearestBridge.filters = [grayFilter];
					
					_nearestBridge.doubleClickEnabled = true;
					_nearestBridge.addEventListener( MouseEvent.DOUBLE_CLICK, removeBridgeRequest );
				}
				else
				{
					_sampleBridge.visible = true;
				}
			}
			else
			{
				_nearestBridgeIndex = 0;
				_nearestBridge = null;
				_nearestBridgeDistance = 0;
				
				_sampleBridge.visible = true;
			}
		}
		
		public function loadBridges( bridgePoints:Array ):void
		{
			for ( var i:int = 0; i < bridgePoints.length; i++ )
			{
				addBridge( 
					bridgePoints[i].bridgeAX,
					bridgePoints[i].bridgeAY,
					bridgePoints[i].bridgeBX,
					bridgePoints[i].bridgeBY
				);
			}
			
			drawAllBridge( );
		}
		
		public function getBridgePoints( ):Array
		{
			var points:Array = [];
			
			for ( var i:int = 0; i < _bridgeDatas.length; i++ )
			{
				points.push( { 
					bridgeAX: _bridgeDatas[i].bridgeA.x,
					bridgeAY: _bridgeDatas[i].bridgeA.y,
					bridgeBX: _bridgeDatas[i].bridgeB.x,
					bridgeBY: _bridgeDatas[i].bridgeB.y
				} )
			}
			
			return points;
		}
		
		protected function snapToGrid( position:Number ):Number
		{
			return BaseUIComponent.snapToGrid( position, PIXEL_SNAP_VALUE );
		}
	}
}