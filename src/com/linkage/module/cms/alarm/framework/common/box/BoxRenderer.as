package com.linkage.module.cms.alarm.framework.common.box
{
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.utils.ArrayUtil;

	public class BoxRenderer extends CheckBox
	{
		private var currData:Object=null;

		public function BoxRenderer()
		{
			super();
			this.addEventListener(Event.CHANGE, onClickCheckBox);
		}

		override public function set data(value:Object):void
		{
			if (value == null)
				return;
			this.selected=value.selected;
			this.currData=value;
			this.label=value.label;
		}

		override public function set enabled(value:Boolean):void
		{
			if (currData)
			{
				value=currData.enabled == false ? false : true;
			}
			super.enabled=value;
		}

		private function onClickCheckBox(e:Event):void
		{
			if (currData == null || listData == null || listData.owner == null)
				return;
			var listBase:AlarmComboBox=AlarmComboBox(listData.owner.owner);
			var selectedItems:Array=listBase.selectedItems;
			currData.selected=this.selected;
			if (this.selected)
			{
				selectedItems.push(currData);
			}
			else
			{
				selectedItems.splice(ArrayUtil.getItemIndex(currData, selectedItems), 1);
			}
			listBase.selectedItems=selectedItems;
		}
	}
}