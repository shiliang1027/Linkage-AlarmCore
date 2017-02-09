package com.linkage.module.cms.alarm.framework.view.columnrenderer
{
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	import com.linkage.module.cms.alarm.framework.common.util.AlarmUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.HBox;
	import mx.controls.CheckBox;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridGroupItemRenderer;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;

	public class TreeCheckBoxRenderer extends AdvancedDataGridGroupItemRenderer
	{
		/**
		 *日志记录器
		 */
		private var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.view.columnrenderer.TreeCheckBoxRenderer");
		/**
		 *复选框
		 */
		private var checkBox:CheckBox = null;
		/**
		 *容器
		 */
		private var hBox:HBox = null;

		public function TreeCheckBoxRenderer()
		{
			super();
			hBox = new HBox();
			hBox.verticalCenter = 0;
			hBox.depth = -100;

			checkBox = new CheckBox();
			checkBox.addEventListener(Event.CHANGE, checkBoxChecked);
		}

		//复选框选择
		private function checkBoxChecked(event:Event):void
		{
			//1.设置告警对象选中属性
			AlarmUtil.addAlarmCheckBox(data, checkBox.selected);

			//2.调用父窗口方法
			parentDocument.checkBoxAlarmMap(data, checkBox.selected);
		}

		override protected function createChildren():void
		{
			super.createChildren();
		}

		override protected function commitProperties():void
		{
			super.commitProperties();
			hBox.percentHeight = 100;
			hBox.percentWidth = 100;
			addChild(hBox);
			addChild(checkBox);
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			//1.设置容器宽高
			var startx:Number = data ? (listData as AdvancedDataGridListData).indent - 6 : 0;
			if (icon)
			{
				startx = icon.x + icon.measuredWidth;
			}
			else
			{
				if (disclosureIcon)
				{
					startx = disclosureIcon.x / 1.6 + disclosureIcon.width;
					disclosureIcon.x = disclosureIcon.x / 1.6;
				}
			}
			//3.设置选中框位置
			checkBox.x = startx;
			checkBox.y = 9;
			//2.设置选中框选中状态
			checkBox.selected = AlarmUtil.checkAlarmCheckBox(data);
		}
	}
}