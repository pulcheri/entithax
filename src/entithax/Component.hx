package entithax;


import entithax.detail.Macro;
using entithax.detail.Macro;

typedef ComponentIdArray = Array<Int>;


#if !macro 
//@:remove
@:autoBuild(entithax.detail.Macro.build_id())
@:autoBuild(entithax.detail.BuildComponent.complete())
#end
interface Component {
	
}
