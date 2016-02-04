package util {
	/**
	 * @author Oleg
	 */
	public class ClassResolver 
	{
		
		private static var _classes : Object = {};

		/**
		 * registers a class for a given id and returns success
		 * @param   theClass the class to be registered
		 * @param   id the id under which the class is to be registered
		 * @param   overwrite if true, the potentially registered class for the id is overwritten
		 * @return
		 */
		public static function registerClass(theClass : Class, id : String, overwrite : Boolean = false) : Boolean {
			var ret : Boolean = overwrite || !_classes.hasOwnProperty(id);
			if (ret) _classes[id] = theClass;
			return ret;
		}

		/**
		 * registers multiple classes and returns an Array of ids, where registration failed
		 * throws an Error, if no class is found where expected
		 * @param   classes an Object mapping ids to classes
		 * @param   overwrite see ClassResolver.registerClass
		 * @return
		 */
		public static function registerClasses(classes : Object, overwrite : Boolean = false) : Array {
			var ret : Array = [];
			for (var id:String in classes) {
				if (classes[id] is Class) {
					if (!registerClass(classes[id], id, overwrite)) ret.push(id);
				} else throw new Error("parameter " + classes[id] + " for id \"" + id + "\" is not a class");
			}
			return ret;
		}

		/**
		 * lookups the class registered for a given id
		 * @param   id
		 * @param   panicIfUndefined if true, lookup to a non existent class will throw an Error
		 * @return
		 */
		public static function getClass(id : String, panicIfUndefined : Boolean = true) : Class 
		{
			if (panicIfUndefined && !_classes.hasOwnProperty(id)) throw new Error("no class registered for id \"" + id + "\"");
			return _classes[id];
		}

		/**
		 * tells whether a class exists for the given id
		 * @param   id
		 * @return
		 */
		public static function classExists(id : String) : Boolean {
			return _classes.hasOwnProperty(id);
		}
	}
}
