package entithax;

import entithax.Group;
import entithax.Component;
import entithax.Entity;
//import thx.HashSet;


class FunctionHolder {
	private var index: Int;
	private var func: GroupChanged;
	
	public function new(index: Int, val: GroupChanged) {
			this.index = index;
			func = val;
	} 

	public function invoke(group: Group, entity: Entity, index: Int, component: Component) {
		func(group, entity, index, component);
	}

    public function hashCode():Int
    {
        return index;
    }

}

//typedef Functions = Array<FunctionHolder>;
typedef Functions = List<GroupChanged>;

class DelegateGroupChanged {
	
	private var functionList = new Functions();

	public function new() {}

	public function invoke(group: Group, entity: Entity, index: Int, component: Component) {
		for (f in functionList) {
			f(group, entity, index, component);
		}
	}

	public function addDelegate(i: Int, f: GroupChanged) {
		//functionList.push(new FunctionHolder(i,f));
		functionList.remove(f);
		functionList.push(f);
	}

	public function removeDelegate(i: Int) {
		
	}
}