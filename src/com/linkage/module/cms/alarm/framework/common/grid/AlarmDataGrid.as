package com.linkage.module.cms.alarm.framework.common.grid
{
	import com.linkage.module.cms.alarm.framework.module.server.source.TreeCollectionView;
	
	import flash.display.Sprite;
	
	import mx.collections.CursorBookmark;
	import mx.collections.HierarchicalCollectionViewCursor;
	import mx.controls.AdvancedDataGrid;

	public class AlarmDataGrid extends AdvancedDataGrid
	{
		private var _rowColorFunction:Function=null;
		private var view:TreeCollectionView=null;
		private var cursor:HierarchicalCollectionViewCursor=null;

		public function AlarmDataGrid()
		{
			super();
		}

		override protected function drawRowBackground(s:Sprite, rowIndex:int, y:Number, height:Number, color:uint, dataIndex:int):void
		{
			if (rowColorFunction != null && dataProvider)
			{
				view=dataProvider as TreeCollectionView;
				if (dataIndex < view.length)
				{
					cursor=view.createCursor() as HierarchicalCollectionViewCursor;
					cursor.seek(CursorBookmark.FIRST, dataIndex);
					var bcolor:uint=_rowColorFunction.call(this, cursor.current);
					color=(bcolor != 0) ? bcolor : color;

				}
			}
			super.drawRowBackground(s, rowIndex, y, height, color, dataIndex);
		}

		public function set rowColorFunction(func:Function):void
		{
			_rowColorFunction=func;
		}

		public function get rowColorFunction():Function
		{
			return _rowColorFunction;
		}
	}
}