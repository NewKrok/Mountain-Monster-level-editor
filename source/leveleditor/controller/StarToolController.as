package leveleditor.controller
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	import leveleditor.BaseUIComponent;
	import leveleditor.EditorWorld;
	
	import rv2.geom.ColorOperator;

	public class StarToolController
	{
		protected const PIXEL_SNAP_VALUE:Number = 1;
		
		protected var grayFilter:ColorMatrixFilter = ColorOperator.adjustSaturation( -1 );
		
		protected var _starViews:Vector.<Star> = new Vector.<Star>;
		
		protected var _sampleStar:Star;
		protected var _starContainer:DisplayObjectContainer;
		
		protected var _nearestStar:Star;
		protected var _nearestStarIndex:int = 0;
		protected var _nearestStarDistance:Number = 0;
		
		protected var editorWorld:EditorWorld;
		
		protected var _isActivated:Boolean = false;
		
		public function StarToolController( editorWorld:EditorWorld, starContainer:DisplayObjectContainer )
		{
			this.editorWorld = editorWorld;
			_starContainer = starContainer;
			
			editorWorld.addChild( _sampleStar = new Star( ) );
			_sampleStar.visible = false;
		}
		
		public function activate( ):void
		{
			_isActivated = true;
			
			_sampleStar.visible = true;
			_sampleStar.mouseChildren = false;
			_sampleStar.mouseEnabled = false;
			_sampleStar.alpha = .3;
			
			editorWorld.addEventListener( MouseEvent.CLICK, addStarRequest );
			editorWorld.addEventListener( MouseEvent.MOUSE_MOVE, onAddStarMouseMove );
		}
		
		public function deactivate( ):void
		{
			_isActivated = false;
			
			_sampleStar.visible = false;
			
			editorWorld.removeEventListener( MouseEvent.CLICK, addStarRequest );
			editorWorld.removeEventListener( MouseEvent.MOUSE_MOVE, onAddStarMouseMove );
		}
		
		protected function onAddStarMouseMove( e:MouseEvent ):void
		{
			_sampleStar.x = snapToGrid( editorWorld.mouseX );
			_sampleStar.y = snapToGrid( editorWorld.mouseY );
			
			setNearestStarFromMouse( );
		}
		
		protected function addStarRequest( e:MouseEvent ):void
		{
			if ( !editorWorld.isWorldDragged( ) )
			{
				if ( _nearestStar && _nearestStar.parent && _nearestStarDistance < 20 )
				{
					removeStar( _nearestStar );
					return;
				}
				else
				{
					addStar( editorWorld.mouseX, editorWorld.mouseY );
				}
			}
		}
		
		protected function addStar( x:Number, y:Number ):void
		{
			var star:Star = new Star( );
			star.buttonMode = true;
			star.x = snapToGrid( x );
			star.y = snapToGrid( y );
			
			_starContainer.addChild( star );
			_starViews.push( star );
			
			if ( _isActivated )
			{
				setNearestStarFromMouse( );
			}
		}
		
		protected function removeStar( star:Star ):void
		{
			_starContainer.removeChild( star );
			
			for ( var i:int = 0; i < _starViews.length; i++ )
			{
				if ( _starViews[i] == star )
				{
					_starViews[i] = null;
					_starViews.splice( i, 1 );
					break;
				}
			}
			
			star = null;
		}
		
		protected function setNearestStarFromMouse( ):void
		{
			if ( _starViews.length > 0 )
			{
				_nearestStar = _starViews[0];
				_nearestStarIndex = 0;
				_nearestStarDistance = Point.distance( new Point( _nearestStar.x, _nearestStar.y ), new Point( editorWorld.mouseX, editorWorld.mouseY ) );
				
				for ( var i:int = 0; i < _starViews.length; i++ )
				{
					_starViews[i].filters = [];
					
					var distance:Number = Point.distance( new Point( _starViews[i].x, _starViews[i].y ), new Point( editorWorld.mouseX, editorWorld.mouseY ) );
					if ( distance < _nearestStarDistance )
					{
						_nearestStarIndex = i;
						_nearestStar = _starViews[i];
						_nearestStarDistance = distance;
					}
				}
				
				if ( _nearestStarDistance < 20 )
				{
					_sampleStar.visible = false;
					_nearestStar.filters = [grayFilter];
				}
				else
				{
					_sampleStar.visible = true;
				}
			}
			else
			{
				_nearestStarIndex = 0;
				_nearestStar = null;
				_nearestStarDistance = 0;
				_sampleStar.visible = true;
			}
		}
		
		public function loadStars( starPoints:Array ):void
		{
			for ( var i:int = 0; i < starPoints.length; i++ )
			{
				addStar( starPoints[i].x, starPoints[i].y );
			}
		}
		
		public function getStarPoints( ):Array
		{
			var points:Array = [];
			
			for ( var i:int = 0; i < _starViews.length; i++ )
			{
				points.push( { x: _starViews[i].x, y: _starViews[i].y } )
			}
			
			return points;
		}
		
		protected function snapToGrid( position:Number ):Number
		{
			return BaseUIComponent.snapToGrid( position, PIXEL_SNAP_VALUE );
		}
	}
}