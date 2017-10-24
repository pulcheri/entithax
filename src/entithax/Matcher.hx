package entithax;

import entithax.Component;
import entithax.Entity;
//import 
using thx.Arrays;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
#end

class Matcher {
	
	private var indicesAllOf_ = new ComponentIdArray();
	private var indicesAnyOf_ = new ComponentIdArray();
	private var indicesNoneOf_ =  new ComponentIdArray();
	private var hashCode_ : Int;

	public function new() {

	}

	public static function
	hashCodeStr(s:String) {
		var hash = 5381, len = s.length;
		for( i in 0...len) hash = ((hash<<5)+hash)+s.charCodeAt(i);
		return hash;
	}

	public static function
	hashCodeArray(arr:ComponentIdArray) {
		var hash = 5381, len = arr.length;
		for( i in 0...len) hash = ((hash<<5)+hash)+ arr[i];
		return hash;
	}

	public static function applyHash(hash: Int, indices: ComponentIdArray, i1: Int, i2: Int) {
		if (indices != null && indices.length > 0) {
			for (i in indices) {
				hash ^= i * i1;
			}
			hash ^= indices.length * i2;
		}
		return hash;
	}

	// Create matcher that matches all indices in a list
	inline public static function allOfIndices(indices: ComponentIdArray) {
		//trace(indices);
		var matcher = new Matcher();
		matcher.indicesAllOf_ = indices;
		matcher.calculateHash();
		return matcher;
	}

	// Convert array of classes to corresponding indices
	public static macro function classesToIndices(indexClasses:Array<ExprOf<Class<Component>>>) {
		var ixs = [for (indexClass in indexClasses) {macro $indexClass.id_ ;}];
		return macro $a{ixs};
	}

	public static macro function allOf(indexClasses:Array<ExprOf<Class<Component>>>) {
		indexClasses = indexClasses.distinct(function(e1, e2) {
        	return e1.toString() == e2.toString();
    	});
		var indices = macro Matcher.classesToIndices($a{indexClasses});
		//var indices2 = macro ($a{indices}.distinct());
		return macro Matcher.allOfIndices($indices);
	}



	// Create matcher that matches none of indices in a list
	public static function noneOf(indices: ComponentIdArray) {
		var matcher = new Matcher();
		matcher.indicesNoneOf_ = indices;
		matcher.calculateHash();
		return matcher;
	}

	private function calculateHash() {
		var hash = 5381;
		hash = applyHash(hash, indicesAllOf_, 3, 53);
		hash = applyHash(hash, indicesAnyOf_, 307, 367);
		hash = applyHash(hash, indicesNoneOf_, 647, 683);
		hashCode_ = hash;
	}

	public function matches(entity: Entity): Bool {
		var matchesAllOf = indicesAllOf_ == null || indicesAllOf_.length == 0 || entity.hasComponents(indicesAllOf_);
		var matchesAnyOf = indicesAnyOf_ == null ||  indicesAnyOf_.length == 0 || entity.hasAnyComponent(indicesAnyOf_);
		var matchesNoneOf = indicesNoneOf_ == null || indicesNoneOf_.length == 0 ||  !entity.hasAnyComponent(indicesNoneOf_);
		return matchesAllOf && matchesAnyOf && matchesNoneOf;
	}

	public function hashCode():Int
    {
		return hashCode_;
    }

	public function allIndices() {
		return indicesAllOf_.concat(indicesAnyOf_).concat(indicesNoneOf_).distinct();
	}

}
