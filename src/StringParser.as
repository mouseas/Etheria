package {
	
	/**
	 * Class designed specifically to parse strings for use in Etheria. All results will be whatever is between the first
	 * and last quote mark in a string.
	 */
	public class StringParser {
		
		public static function readInt(str:String):int {
			var start:int = str.indexOf("\"");
			var end:int = str.lastIndexOf("\"");
			if (start + 1 < end) {
				var result:String = str.substring(start + 1, end);
				//trace(result);
				return int(result);
			} else {
				trace("readInt error! [" + start + " to " + end + "] Contents: " + str);
				return 0;
			}
		}
		
		public static function readNumber(str:String):Number {
			var start:int = str.indexOf("\"");
			var end:int = str.lastIndexOf("\"");
			if (start + 1 < end) {
				var result:String = str.substring(start + 1, end);
				//trace(result);
				return Number(result);
			} else {
				trace("readNumber error! [" + start + " to " + end + "] Contents: " + str);
				return 0;
			}
		}
		
		public static function readString(str:String):String {
			var start:int = str.indexOf("\"");
			var end:int = str.lastIndexOf("\"");
			if (start + 1 < end) {
				var result:String = str.substring(start + 1, end);
				while (result.indexOf("^^^") > -1) {
					result = result.replace("^^^", "\n");
					//replaces "^^^" with new lines. This way a series of paragraphs can be saved/loaded from one string.
				}
				//trace(result);
				return result;
			} else {
				trace("readString error! [" + start + " to " + end + "] Contents: " + str);
				return "";
			}
		}
		
		public static function readValue(str:String):String {
			var start:int = str.indexOf("\"");
			var end:int = str.lastIndexOf("\"");
			if (start + 1 < end) {
				var result:String = str.substring(start + 1, end);
				/*var canBeInt:Boolean = false;
				var canBeNumber:Boolean = false;
				var justAString:Boolean = false;
				if (!isNaN(parseInt(result)) && parseInt(result) - parseFloat(result) == 0) {
					canBeInt = true;
				} else if (!isNaN(parseFloat(result))) {
					canBeNumber = true;
				} else {
					justAString = true;
				}
				trace(result + " i:" + canBeInt + " n:" + canBeNumber + " s:" + justAString);*/
				return result;
			} else {
				trace("readValue error! [" + start + " to " + end + "] Contents: " + str);
				return "";
			}
		}
		
		public static var pattern:RegExp = /[a-zA-Z01-9]/;
		
		public static function readVarName(str:String):String {
			var end:int = 0;
			while (str.charAt(end).match(pattern) != null) {
				end++;
			}
			if (end > 0) {
				var result:String = str.substring(0, end);
				//trace(result);
				return (result);
			} else {
				trace("readVarName error! [0 to " + end + "] Contents: " + str);
				return "";
			}
		}
		
		/**
		 * Takes a string from an Etheria-related text file, pulls a variable name and value
		 * @param	source The string from which to pull variable and value
		 * @param	parent The object to which the variable should be assigned.
		 * @return Whether the variable assignment was successful
		 */
		public static function assignValueFromStrings(source:String, parent:*):Boolean {
			var preValue:String = readValue(source);
			var variable:String = readVarName(source);
			try {
				if(source.length > 0 && variable.length > 0) { // This way it skips blank lines and undefined variables.
					if (!isNaN(parseInt(preValue)) && parseInt(preValue) - parseFloat(preValue) == 0) {
						var valueInt:int = parseInt(preValue);
						parent[variable] = valueInt;
					} else if (!isNaN(parseFloat(preValue))) {
						var valueNum:Number = parseFloat(preValue);
						parent[variable] = valueNum;
					} else if ((preValue.indexOf("true") > -1 && preValue.length < 5) || (preValue.indexOf("false") > -1 && preValue.length < 6)) { 
						// Considered a boolean only if the value is exactly "true" or "false" (length taken into account
						// This prevents strings from being mistaken as booleans because they contain "true" or "false" in
						// them somewhere. Note that "true " parses as a string, so get the quote marks right.
						if (preValue.indexOf("true") > -1) {
							parent[variable] = true;
						} else {
							parent[variable] = false;
						}
					} else {
						var valueStr:String = preValue;
						parent[variable] = valueStr;
					}
				}
				
			} catch (e:Error) {
				return false;
				trace("ERROR: " + e.name + " - " + e.message);
			}
			return true;
			
		}
		
		
		
		
		
		
		
		
	}
	
	
}