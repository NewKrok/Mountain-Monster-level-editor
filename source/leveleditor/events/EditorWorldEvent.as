package leveleditor.events
{
	import flash.events.Event;
	
	import leveleditor.data.LevelDataVO;

	public class EditorWorldEvent extends Event
	{
		public static var ON_VIEW_RESIZE:String = 'EditorWorldEvent.ON_VIEW_RESIZE';
		
		public var data:*;
		
		public function EditorWorldEvent( type:String, data:* = null )
		{
			this.data = data;
			
			super( type );
		}
	}
}