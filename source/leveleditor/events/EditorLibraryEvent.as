/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor.events
{
	import flash.events.Event;

	import leveleditor.assets.library.LibraryElementVO;

	public class EditorLibraryEvent extends Event
	{
		public static var OPEN_REQUEST:String = 'EditorLibraryEvent.OPEN_REQUEST';
		public static var ADD_ELEMENT_TO_WORLD_REQUEST:String = 'EditorLibraryEvent.ADD_ELEMENT_TO_WORLD_REQUEST';
		public static var REMOVE_ELEMENT_FROM_WORLD_REQUEST:String = 'EditorLibraryEvent.REMOVE_ELEMENT_FROM_WORLD_REQUEST';

		public var libraryElementVO:LibraryElementVO;

		public function EditorLibraryEvent( type:String, libraryElementVO:LibraryElementVO = null )
		{
			super( type );
			this.libraryElementVO = libraryElementVO;
		}

		override public function clone():Event
		{
			return new EditorLibraryEvent( this.type, this.libraryElementVO );
		}
	}
}