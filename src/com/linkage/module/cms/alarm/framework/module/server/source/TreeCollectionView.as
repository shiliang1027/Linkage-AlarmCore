package com.linkage.module.cms.alarm.framework.module.server.source
{
	import mx.collections.HierarchicalCollectionView;
	import mx.collections.IHierarchicalData;

	public class TreeCollectionView extends HierarchicalCollectionView
	{
		//是否刷新
		private var _isRefresh:Boolean=true;

		public function TreeCollectionView(hierarchicalData:IHierarchicalData=null, argOpenNodes:Object=null)
		{
			super(hierarchicalData, argOpenNodes);
		}

		override public function refresh():Boolean
		{
			if (isRefresh)
			{
				return super.refresh();
			}
			return false;
		}

		//手动刷新
		public function refreshByHand():Boolean
		{
			return super.refresh();
		}

		public function get isRefresh():Boolean
		{
			return _isRefresh;
		}

		public function set isRefresh(value:Boolean):void
		{
			_isRefresh=value;
		}
	}
}