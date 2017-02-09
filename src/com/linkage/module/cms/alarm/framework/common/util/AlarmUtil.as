package com.linkage.module.cms.alarm.framework.common.util
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.StringUtil;
	import com.ailk.common.system.logging.ILogger;
	import com.ailk.common.system.logging.Log;
	import com.linkage.module.cms.alarm.framework.AlarmContainer;
	import com.linkage.module.cms.alarm.framework.common.param.ColumnConstants;
	
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.core.IFlexModuleFactory;

	/**
	 *告警相关工具类
	 * @author mengqiang
	 *
	 */
	public class AlarmUtil
	{
		/**
		 *日志记录器
		 */
		private static var log:ILogger = Log.getLogger("com.linkage.module.cms.alarm.framework.common.util.AlarmUtil");
		/**
		 * 弹出页面参数支持的key
		 */
		private static const WINDOW_OPEN_KEYS:Array = ["status", "toolbar", "location", "resizable", "menubar", "top", "left", "width", "height"];
		/**
		 * 弹出页面的默认参数对象
		 */
		private static const WINDOW_OPEN_PARAM:Object = {"status": "no", "toolbar": "no", "location": "no", "resizable": "yes", "menubar": "no", "top": "10", "left": "10"};
		/**
		 * 弹出页面的默认参数
		 */
		private static const DEFAULT_WINDOW_OPEN_PARAM:String = "scrollbars=yes,status=no,toolbar=no,location=no,resizable=yes,menubar=no,top=10,left=10";

		/**
		 * 初始化默认排序的sort(不管表格中点击哪列排序,这个sort里面的第一个field始终会被加到最后进行排序)
		 * @return
		 *
		 */
		public static function initDefaultSort():Sort
		{
			var sort:Sort = new Sort();
			sort.fields = [new SortField(ColumnConstants.KEY_DalTime, true, true)];
			return sort;
		}

		/**
		 * 初始化排序的sort通过表头KEY
		 * @param filed 排序列字段
		 * @param descending 是否按降序排列
		 * @return
		 *
		 */
		public static function initFiledSort(filed:String, descending:Boolean = true):Sort
		{
			var sort:Sort = new Sort();
			sort.fields = [new SortField(filed, true, descending)];
			return sort;
		}

		/**
		 *默认过滤器
		 * @param alarm
		 * @return
		 *
		 */
		public static function defaultFilterFunction(alarm:Object):Boolean
		{
			return true;
		}

		/**
		 *验证告警展示列
		 * @param columnName
		 * @param windowType
		 * @return
		 *
		 */
		public static function checkColumn(columnName:String, windowType:int):Boolean
		{
			//log.info("验证告警展示列" + columnName + "," + windowType);
			if(windowType == 1 || windowType == 2)
			{
				if(columnName == ColumnConstants.KEY_CancelTimeLabel)
				{
					return true;
				}
			}
			return false;
		}
		
		/**
		 *导出子告警树形信息
		 * @param alarm
		 * @return
		 *
		 */
		public static function exportAlarmPreInfo(alarm:Object):String
		{
			if (alarm.parent == null)
			{
				return "";
			}
			var result:String = "[children]|------";
			return exportChildrenInfo(alarm.parent, result);
		}

		/**
		 * 导出子告警树形信息
		 * @param alarm
		 * @param result
		 * @return
		 *
		 */
		public static function exportChildrenInfo(alarm:Object, result:String):String
		{
			if (alarm.parent == null)
			{
				return result;
			}
			result = "[children]" + result;
			return exportChildrenInfo(alarm.parent, result);
		}

		/**
		 * 给告警中添加锁定的属性
		 * @param alarm 告警对象
		 * @param locked 是否锁定
		 *
		 */
		public static function addLockField(alarm:Object, locked:Boolean = false):void
		{
			if (alarm != null)
			{
				alarm[AlarmContainer.INTERNALKEY_LOCKED] = locked ? 1 : 0;
			}
		}

		/**
		 *验证告警专业
		 * @param alarm 告警
		 * @return
		 *
		 */
		public static function checkAlarmSpecialty(alarm:Object):Boolean
		{
			return alarm[ColumnConstants.KEY_Specialty] >= 1 && alarm[ColumnConstants.KEY_Specialty] <= 9;
		}

		/**
		 * 验证告警是否处于锁定状态
		 * @param alarm
		 * @return
		 *
		 */
		public static function checkAlarmLocked(alarm:Object):Boolean
		{
			return alarm[AlarmContainer.INTERNALKEY_LOCKED] == 1 ? true : false;
		}

		/**
		 *获取告警唯一序列ID
		 * @param alarm
		 * @return
		 *
		 */
		public static function getAlarmUniqueId(alarm:*):String
		{
			return (alarm == null) ? null : alarm[ColumnConstants.KEY_AlarmUniqueId];
		}

		/**
		 *验证当前告警树是否全是清除告警
		 * @param alarm
		 * @return
		 *
		 */
		public static function checkTreeAllClearAlarm(alarm:Object):Boolean
		{
			var topAlarm:Object = findTopParentAlarm(alarm);
			var alarmArray:ArrayCollection = findAllChildAlarmList(topAlarm);
			for each (var treeAlarm:Object in alarmArray)
			{
				if (checkActive(treeAlarm))
				{
					return false;
				}
			}
			return true;
		}

		/**
		 *验证当前告警树是否全是确认告警
		 * @param alarm
		 * @return
		 *
		 */
		public static function checkTreeAllAckAlarm(alarm:Object):Boolean
		{
			var topAlarm:Object = findTopParentAlarm(alarm);
			var alarmArray:ArrayCollection = findAllChildAlarmList(topAlarm);
			for each (var treeAlarm:Object in alarmArray)
			{
				if (checkUnack(treeAlarm))
				{
					return false;
				}
			}
			return true;
		}

		/**
		 *排序告警子数组
		 * @param alarm
		 *
		 */
		public static function sortAlarmChildrenArray(alarm:Object):void
		{
			if (alarm != null && alarm.children != null)
			{
				var children:ArrayCollection = alarm.children;
				var source:Array = children.source;
				source.sort(compareFunction);
			}
		}

		/**
		 *对对象按发生时间进行排序
		 * @param obj1 对象1
		 * @param obj2 对象2
		 * @return
		 *
		 */
		public static function compareFunction(obj1:Object, obj2:Object):int
		{
			var time1:int = obj1[ColumnConstants.KEY_EventTime];
			var time2:int = obj2[ColumnConstants.KEY_EventTime];
			if (time1 > time2)
			{
				return 1;
			}
			else if (time1 < time2)
			{
				return -1;
			}
			return 0;
		}

		/**
		 *获取顶级父告警
		 * @param alarm
		 *
		 */
		public static function findTopParentAlarm(alarm:Object):Object
		{
			if (alarm.parent == null)
			{
				return alarm;
			}
			return findTopParentAlarm(alarm.parent);
		}

		/**
		 *字符串转换为JSON对象
		 * @param str 字符串
		 * @return JSON对象
		 *
		 */
		public static function jsonDecode(str:String):Object
		{
			return JSON.decode(str.replace(/\'/g, "\""));
		}

		/**
		 * 给告警中添加选中的属性
		 * @param alarm 告警对象
		 * @param selected 是否锁定
		 *
		 */
		public static function addAlarmCheckBox(alarm:Object, selected:Boolean = false):void
		{
			if (alarm != null)
			{
				alarm[ColumnConstants.KEY_Internal_Checked] = selected ? 1 : 0;
			}
		}

		/**
		 * 验证告警是否处于选中状态
		 * @param alarm 告警对象
		 * @return
		 *
		 */
		public static function checkAlarmCheckBox(alarm:Object):Boolean
		{
			if (alarm == null)
			{
				return false;
			}
			return alarm[ColumnConstants.KEY_Internal_Checked] == 1 ? true : false;
		}

		/**
		 *验证字符串是否为空
		 * @param str
		 * @return
		 *
		 */
		public static function checkStrIsNull(str:Object):Boolean
		{
			return (str == null || str == '' || str == 'null' || str == 'undefined') ? false : true;
		}

		/**
		 *验证字符串是否为空
		 * @param str
		 * @return
		 *
		 */
		public static function checkStrNull(str:String):String
		{
			return (str == null || str == '' || str == 'null' || str == 'undefined') ? null : str;
		}

		/**
		 *验证窗口类型 true:活动告警 false:清除告警
		 * @param windowType 窗口类型
		 * @return
		 *
		 */
		public static function checkWindowType(windowType:int):Boolean
		{
			return (windowType == 1 || windowType == 3 || windowType == 5) ? true : false;
		}

		/**
		 * 克隆对象
		 * @param source
		 * @return
		 *
		 */
		public static function cloneObject(source:Object):Object
		{
			var target:Object = new Object();
			if (source != null)
			{
				for (var key:String in source)
				{
					target[key] = source[key];
				}
			}
			return target;
		}

		/**
		 * 克隆告警对象
		 * @param source
		 * @param property
		 * @return
		 *
		 */
		public static function cloneAlarmMinusProperty(source:Object, property:String):Object
		{
			var target:Object = new Object();
			if (source != null)
			{
				for (var key:String in source)
				{
					if (key != property)
					{
						target[key] = source[key];
					}
				}
			}
			return target;
		}

		/**
		 * 复制告警对象
		 * @param source
		 * @return
		 *
		 */
		public static function copySourceToTarget(source:Object, target:Object):Object
		{
			if (source != null && target != null)
			{
				for (var key:String in source)
				{
					target[key] = source[key];
				}
			}
			return target;
		}

		/**
		 * 获取Map的值
		 * @param map
		 * @param key
		 * @param defaultValue
		 * @return
		 *
		 */
		public static function getMapValue(map:Object, key:*, defaultValue:* = null):*
		{
			var value:String = map[key];
			return value != null ? value : (defaultValue != null ? defaultValue : key);
		}

		/**
		 * 获取告警展示列宽度
		 * @param map
		 * @param key
		 * @param Value
		 * @return
		 *
		 */
		public static function getColumnWidth(map:Object, key:*, value:*):*
		{
			if (map[key] != null)
			{
				return map[key];
			}
			return (String(value).length + 1) * 16;
		}

		/**
		 *验证告警是否有关联关系
		 * @param alarm 告警对象
		 *
		 */
		public static function checkRelationFlag(alarm:Object):Boolean
		{
			return alarm[ColumnConstants.KEY_RelatedFlag] == 1 || alarm[ColumnConstants.KEY_RelatedFlag] == "1";
		}

		/**
		 * 显示提示信息
		 * @param text
		 * @param title
		 * @param flags
		 * @param parent
		 * @param closeHandler
		 * @param iconClass
		 * @param defaultButtonFlag
		 * @param moduleFactory
		 *
		 */
		public static function showMessage(text:String = "", title:String = "消息", flags:uint = 0x4, parent:Sprite = null, closeHandler:Function = null, iconClass:Class = null, defaultButtonFlag:uint = 0x4, moduleFactory:IFlexModuleFactory = null):void
		{
			Alert.show(text, title, flags, parent, closeHandler, iconClass, defaultButtonFlag, moduleFactory);
		}

		/**
		 *获取表格背景颜色
		 * @param data
		 * @param windowType 1：活动窗口 0：清除窗口
		 * @return
		 *
		 */
		public static function getDataGridBackColor(data:Object, windowType:int):uint
		{
			if (checkAlarmCheckBox(data)) //选中告警：深蓝
			{
				return 0x0e2f47;
			}
			if (windowType == 1 && data != null && !checkActive(data)) //清除告警：灰色
			{
				return 0x6a6f72;
			}
			return 0;
		}

		/**
		 *获取告警等级颜色
		 * @param data
		 * @return
		 *
		 */
		public static function getAlarmColor(data:Object):uint
		{
			if (data.hasOwnProperty(ColumnConstants.KEY_AlarmSeverityColorLabel))
			{
				return data[ColumnConstants.KEY_AlarmSeverityColorLabel];
			}
			return 0x4169e1;
		}
		/**
		 *获取网管告警等级颜色
		 * @param data
		 * @return
		 *
		 */
		public static function getJTAlarmColor(data:Object):uint
		{
			if (data.hasOwnProperty(ColumnConstants.KEY_JT_AlarmSeverityColorLabel))
			{
				return data[ColumnConstants.KEY_JT_AlarmSeverityColorLabel];
			}
			return 0x4169e1;
		}
		

		/**
		 *获取自定义告警等级颜色
		 * @param data
		 * @return
		 *
		 */
		public static function getAlarmEmergencyColor(data:Object):uint
		{
			if (data.hasOwnProperty(ColumnConstants.KEY_AlarmEmergencyColorLabel))
			{
				return data[ColumnConstants.KEY_AlarmEmergencyColorLabel];
			}
			return 0x4169e1;
		}

		/**
		 * 返回告警的较高等级 (目前是数字越低,级别越高,但是不能为负数)
		 * @param level1
		 * @param level2
		 * @return
		 *
		 */
		public static function maxAlarmLevel(level1:int, level2:int):int
		{
			if (level1 == 0)
			{
				return level2;
			}
			if (level2 == 0)
			{
				return level1;
			}
			return level1 < level2 ? level1 : level2;
		}

		/**
		 *获取所有子孙及自己告警列表
		 * @param alarm 告警对象
		 * @return 所有子孙及自己告警列表
		 *
		 */
		public static function findAllChildAlarmList(alarm:Object):ArrayCollection
		{
			var allArray:ArrayCollection = new ArrayCollection();
			allArray.addItem(alarm);
			findAllChildAlarm(allArray, alarm)
			return allArray;
		}

		/**
		 *获取所有子孙告警列表
		 * @param allArray 存放告警列表
		 * @param alarm 自身告警对象
		 *
		 */
		private static function findAllChildAlarm(allArray:ArrayCollection, alarm:Object, level:int = 1):void
		{
			var children:ArrayCollection = alarm.children;
			//如果没有子告警、层次大于等于5直接退出
			if (level++ >= 5 || children == null || children.length == 0)
			{
				return;
			}
			for each (var child:Object in children)
			{
				allArray.addItem(child);
				findAllChildAlarm(allArray, child, level);
			}
		}

		/**
		 * 验证是否是活动告警
		 * @param alarm
		 * @return
		 *
		 */
		public static function checkActive(alarm:Object):Boolean
		{
			return alarm[ColumnConstants.KEY_AlarmStatus] == 1;
		}

		/**
		 * 验证是否是基站告警
		 * @param alarm
		 * @return
		 *
		 */
		public static function checkBtsType(alarm:Object):Boolean
		{
			return checkStrIsNull(alarm[ColumnConstants.KEY_AlarmBtsType]);
		}

		/**
		 * 验证是否是未确认告警
		 * @param alarm
		 * @return
		 *
		 */
		public static function checkUnack(alarm:Object):Boolean
		{
			return alarm[ColumnConstants.KEY_AckFlag] == 0;
		}

		/**
		 *更新批量告警信息
		 * @param update 更新信息
		 * @param alarm 告警对象
		 *
		 */
		public static function updateMultAlarm(update:String, alarms:Array):void
		{
			if (update == null || update == '')
			{
				return;
			}
			var array:Array = null;
			var updateArray:Array = update.split("|");
			for each (var alarm:Object in alarms)
			{
				for each (var updateStr:String in updateArray)
				{
					array = updateStr.split("=");
					if (array != null && array.length == 2)
					{
						var key:String = array[0];
						var value:String = array[1];
						alarm[key] = value;
					}
				}
			}
		}

		/**
		 * 解析宏表达式 (替换 $[*] 之间的内容)
		 * @param input
		 * @param alarm 告警对象
		 * @return
		 *
		 */
		public static function parseMacro(input:String, alarm:Object):String
		{
			if (input == null)
			{
				return null;
			}

			var pos:int = -1;
			var end:int = -1;
			var originalValue:String = null;
			var replaceValue:String = null;

			for (pos = input.indexOf("$["); pos != -1; pos = input.indexOf("$["))
			{

				end = input.indexOf("]", pos);

				if (end == -1)
				{
					return input;
				}
				originalValue = input.substring(pos + 2, end);
				replaceValue = alarm[originalValue];

				if (replaceValue != null)
				{
					input = input.replace("$[" + originalValue + "]", replaceValue);
				}
				else
				{
					input = input.replace("$[" + originalValue + "]", "");
				}

			}
			return input;
		}

		/**
		 * 解析批量宏表达式
		 * @param input
		 * @param alarms
		 * @return
		 *
		 */
		public static function parseMultMacro(input:String, alarms:Array):String
		{
			if (input == null)
			{
				return null;
			}

			var pos:int = -1;
			var end:int = -1;
			var originalValue:String = null;
			var replaceValue:String = null;

			var splitStart:String = "$MULT_START";
			var splitEnd:String = "$MULT_END";
			for (pos = input.indexOf(splitStart); pos != -1; pos = input.indexOf(splitStart))
			{
				end = input.indexOf(splitEnd, pos);
				if (end == -1)
				{
					return input;
				}
				originalValue = input.substring(pos + splitStart.length, end);
				replaceValue = "";
				alarms.forEach(function(item:*, index:int, array:Array):void
					{
						replaceValue += parseMacro(originalValue, item);
					});
				input = input.replace(splitStart + originalValue + splitEnd, replaceValue);
			}
			return input;
		}

		/**
		 * 从url中提取不带参数的部分
		 * @param url
		 * @return
		 *
		 */
		public static function getUrlWithoutVariables(url:String):String
		{
			var index:int = url.indexOf("?");
			if (index == -1)
			{
				return url;
			}
			return url.substring(0, index);
		}

		/**
		 * 从url中提取参数
		 * @param url
		 * @return
		 *
		 */
		public static function getUrlVariables(url:String):URLVariables
		{
			var params:URLVariables = new URLVariables();
			var index:int = url.indexOf("?");
			if (index == -1)
			{
				return params;
			}
			var vars:String = url.substring(index + 1);
			var array:Array = vars.split("&");
			array.forEach(function(item:String, index:int, arr:Array):void
				{
					var keyValue:Array = item.split("=");
					params[keyValue[0]] = keyValue[1];
				});
			return params;
		}

		/**
		 *还原列字段信息
		 * @param filed
		 * @return
		 *
		 */
		public static function recoverColumn(filed:String):String
		{
			return filed.replace("_label", "");
		}

		/**
		 *创建唯一集客业务ID  集客ID+业务ID
		 * @return
		 *
		 */
		public static function buildUniqueCustbussId(alarm:Object):String
		{
			return alarm[ColumnConstants.KEY_GroupCustomerId] + "-" + alarm[ColumnConstants.KEY_CusBussId];
		}

		/**
		 *验证是否有子告警
		 * @param alarm 告警
		 * @return
		 *
		 */
		public static function haveChildren(alarm:Object):Boolean
		{
			return alarm.children != null ? true : false;
		}

		/**
		 * 弹出URL
		 *
		 * @param url
		 * @param name
		 * @param param  格式如：{width:500,height:300}
		 *
		 */
		public static function openUrl(url:String, name:String = null, param:Object = null):void
		{
			var openParam:String = DEFAULT_WINDOW_OPEN_PARAM;
			if (param)
			{
				var array:Array = [];
				WINDOW_OPEN_KEYS.forEach(function(key:String, index:int, array1:Array):void
					{
						if (param[key])
						{
							array.push(key + "=" + param[key]);
						}
						else if (WINDOW_OPEN_PARAM[key])
						{
							array.push(key + "=" + WINDOW_OPEN_PARAM[key]);
						}
					});
				openParam = array.join(",");
			}
			log.warn("window.open({0}, {1}, {2})", url, name, openParam);
			ExternalInterface.call("function(){window.open('" + StringUtil.trim(url) + "'," + (name == null ? "''" : "'" + name + "'") + ",'" + openParam + "')}");
		}

		private static function printObject(object:Object):String
		{
			var array:Array = [];
			for (var i:String in object)
			{
				array.push(i + "=" + object[i]);
			}
			return array.join(",");
		}

		/**
		 *转码
		 * @param str
		 * @return
		 *
		 */
		public static function encodeUtf8(str:String):String
		{
			if (str != null && str != "undefined")
			{
				var oriByteArr:ByteArray = new ByteArray();
				oriByteArr.writeUTFBytes(str);
				var tempByteArr:ByteArray = new ByteArray();
				for (var i:Number = 0; i < oriByteArr.length; i++)
				{
					if (oriByteArr[i] == 194)
					{
						tempByteArr.writeByte(oriByteArr[i + 1]);
						i++;
					}
					else if (oriByteArr[i] == 195)
					{
						tempByteArr.writeByte(oriByteArr[i + 1] + 64);
						i++;
					}
					else
					{
						tempByteArr.writeByte(oriByteArr[i]);
					}
				}
				tempByteArr.position = 0;
				return tempByteArr.readMultiByte(tempByteArr.bytesAvailable, "chinese");
			}
			else
			{
				return "";
			}
		}
	}
}