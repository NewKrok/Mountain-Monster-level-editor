package leveleditor.events
{
	import flash.events.Event;

	public class MenuEvent extends Event
	{
		public static var IMPORT_REQUEST:String = 'MenuEvent.IMPORT_REQUEST';
		public static var EXPORT_REQUEST:String = 'MenuEvent.EXPORT_REQUEST';
		public static var CHANGE_CAMERA_VIEW_VISIBILITY:String = 'MenuEvent.CHANGE_CAMERA_VIEW_VISIBILITY';
		public static var JUMP_VIEW_TO_START_REQUEST:String = 'MenuEvent.JUMP_VIEW_TO_START_REQUEST';
		public static var JUMP_VIEW_TO_END_REQUEST:String = 'MenuEvent.JUMP_VIEW_TO_END_REQUEST';
		public static var SET_CONTROL_TO_SELECT:String = 'MenuEvent.SET_CONTROL_TO_SELECT';
		public static var SET_CONTROL_TO_ADD:String = 'MenuEvent.SET_CONTROL_TO_ADD';
		public static var SET_CONTROL_TO_REMOVE:String = 'MenuEvent.SET_CONTROL_REMOVE';
		public static var SET_CONTROL_TO_STAR:String = 'MenuEvent.SET_CONTROL_TO_STAR';
		public static var SET_CONTROL_TO_BRIDGE:String = 'MenuEvent.SET_CONTROL_TO_BRIDGE';
		public static var ZOOM_IN_REQUEST:String = 'MenuEvent.ZOOM_IN_REQUEST';
		public static var ZOOM_OUT_REQUEST:String = 'MenuEvent.ZOOM_OUT_REQUEST';
		public static var CLOSE_REQUEST:String = 'MenuEvent.CLOSE_REQUEST';
		
		public function MenuEvent( type:String )
		{
			super( type );
		}
	}
}