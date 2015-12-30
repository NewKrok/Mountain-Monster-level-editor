/**
 * Created by newkrok on 29/12/15.
 */
package leveleditor.assets.library
{
	public class EditorLibraryAssets
	{
		public static const TYPE_CRATE:String = 'EditorLibraryAssets.TYPE_CRATE';

		public static const SCALE_FACTOR:Number = 0.5;

		private const _elements:Vector.<LibraryElementVO> = new <LibraryElementVO>[
				new LibraryElementVO( TYPE_CRATE, 'crate_0' ),
				new LibraryElementVO( TYPE_CRATE, 'crate_1' ),
				new LibraryElementVO( TYPE_CRATE, 'crate_2' ),
				new LibraryElementVO( TYPE_CRATE, 'crate_3' ),
				new LibraryElementVO( TYPE_CRATE, 'crate_4' ),
				new LibraryElementVO( TYPE_CRATE, 'crate_5' )
		];

		public function getElementsByType( type:String ):Vector.<LibraryElementVO>
		{
			var result:Vector.<LibraryElementVO> = new <LibraryElementVO>[];
			var length:int = this._elements.length;

			for( var i:int = 0; i < length; i++ )
			{
				if ( this._elements[i].type == type )
				{
					result.push( this._elements[i] );
				}
			}

			return result;
		}
	}
}