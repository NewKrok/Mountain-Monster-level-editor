package leveleditor.events
{
	import flash.events.Event;
	
	import leveleditor.data.LevelData;

	public class ImportEvent extends Event
	{
		public static var DATA_IMPORTED:String = 'ImportEvent.DATA_IMPORTED';
		
		public var levelData:LevelData;
		
		public function ImportEvent( type:String, levelData:LevelData = null )
		{
			this.levelData = levelData;
			
			super( type );
		}
	}
}