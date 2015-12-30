package leveleditor.events
{
	import flash.events.Event;
	
	import leveleditor.data.LevelDataVO;

	public class ImportEvent extends Event
	{
		public static var DATA_IMPORTED:String = 'ImportEvent.DATA_IMPORTED';
		
		public var levelData:LevelDataVO;
		
		public function ImportEvent( type:String, levelData:LevelDataVO = null )
		{
			this.levelData = levelData;
			
			super( type );
		}
	}
}