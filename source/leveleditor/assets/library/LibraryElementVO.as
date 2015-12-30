/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor.assets.library
{
	import flash.geom.Point;

	public class LibraryElementVO
	{
		public var type:String;
		public var className:String;

		public var position:Point;
		public var scale:Number = 1;

		public function LibraryElementVO( type:String, className:String )
		{
			this.type = type;
			this.className = className;
		}

		public function clone():LibraryElementVO
		{
			var libraryElementVO:LibraryElementVO = new LibraryElementVO( this.type, this.className );
			libraryElementVO.position = this.position;

			return libraryElementVO;
		}
	}
}