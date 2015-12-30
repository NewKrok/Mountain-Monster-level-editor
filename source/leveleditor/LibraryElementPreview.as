/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;

	import leveleditor.assets.library.EditorLibraryAssets;

	import leveleditor.assets.library.LibraryElementVO;

	public class LibraryElementPreview extends Sprite
	{
		private var _libraryElementVO:LibraryElementVO;

		public function LibraryElementPreview( libraryElementVO:LibraryElementVO )
		{
			this._libraryElementVO = libraryElementVO;

			this.buildView();
		}

		private function buildView():void
		{
			var classRef:Class = getDefinitionByName( this._libraryElementVO.className ) as Class;

			var bitmap:Bitmap = new Bitmap( new classRef );
			bitmap.scaleX = bitmap.scaleY = EditorLibraryAssets.SCALE_FACTOR;

			this.addChild( bitmap );
		}

		public function getLibraryElementVO():LibraryElementVO
		{
			return this._libraryElementVO;
		}
	}
}