package entithax.detail;


import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Tools;
import haxe.macro.ExprTools;


import entithax.Component;

class Macro {
//#if (macro)
//	public static function build(): Array<Field> {
	macro static public function build_id() : Array<Field> {
 		var fields = Context.getBuildFields();
		
		trace('fromBaseClass:  ${Context.getLocalType()} ; id = ${nextId_}');

		fields.push({
			name: "id_",
			access: [Access.APublic, Access.AStatic, Access.AInline],
			kind: FieldType.FVar(macro: Int, macro $v{nextId_}),
			pos: Context.currentPos(),
			});
		nextId_++;
		//fields.concat(fields2);
		return fields;
	}
//#end




    public static macro function getComponentId(object:ExprOf<Component>): Expr {
        var name = switch (Context.typeof(object)) {
            case TInst(_.get() => t, _): t.name;
            case _: {
				trace(object);
				throw "object type not found";
			}
        }
		trace(name);
        return macro $i{name}.id_;
    }

	public static macro function getComponentId2(e:Expr) {
		//var nameCode : String = ExprTools.toString(e);
		//var name = Context.parse(nameCode, Context.currentPos());
		var name =  macro $e;

		return name;
	}

	private static var nextId_ = 0;
}
