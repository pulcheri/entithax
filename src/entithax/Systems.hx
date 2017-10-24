package entithax;

import entithax.Context;
import entithax.Entity;
import entithax.Collector;

interface ISystem {

}

/// Implement this interface if you want to create a system which should be
/// executed every frame.
interface IExecuteSystem extends ISystem {
	public function execute(): Void;
} 

/// Implement this interface if you want to create a system which should be
/// initialized once in the beginning.
interface IInitializeSystem extends ISystem {
	public function initialize(): Void;
}

interface IReactiveSystem extends IExecuteSystem {
	public function activate(): Void;
	public function deactivate(): Void;
	public function clear(): Void;
}

class DemoInitializeSystem implements IInitializeSystem {
	public function new () {}
	public function initialize() {
		trace("Demo system initialized.");
	}
}

class DemoExecuteSystem implements IExecuteSystem implements IInitializeSystem {
	private var context: Context;
	
	public function new(context: Context) {
		this.context = context;
	}

	public function initialize() {
		trace("DemoExecuteSystem initialized!");
		//var e = context.createEntity();
		//e.addComponent
	}

	public function execute() {
		//trace("execute");
	}
}

class ReactiveSystem implements IReactiveSystem {
	private var context: Context;
	private var collector: Collector;
	private var collectedEntities = new Array<Entity>();

	public function new(collector: Collector) {
		this.collector = collector;
	}

	public function activate() {
		collector.activate();
	}

	public function deactivate() {
		collector.deactivate();
	}

	public function clear() {
		collector.clearCollected();
	}

	private function executeEntities(entities: Array<Entity>) {
		trace("Must be implemented by child class!");
	}

	public function execute() {
		if (collector.collectedEntities.length > 0) {
			for (e in collector.collectedEntities) {
				collectedEntities.push(e);
			}
			collector.clearCollected();

			if (collectedEntities.length > 0){
				executeEntities(collectedEntities);
			}

			collectedEntities = new Array<Entity>();
		}
	}
}



class Systems implements IInitializeSystem implements IExecuteSystem {
	private var initializeSystems = new List<IInitializeSystem>();
	private var executeSystems = new List<IExecuteSystem>();

	public function new() {

	}
	public function execute() {
		//for (s in executeSystems) s.execute();
		//jexecuteSystems.map(function (x) { x.execute() } );
		Lambda.iter(executeSystems, function (x) x.execute());
	}

	public function initialize() {
		for (s in initializeSystems) s.initialize();
	}

	public function add(system: ISystem) {
		if (Std.is(system, IExecuteSystem))
			executeSystems.push(cast system);
		if (Std.is(system, IInitializeSystem))
			initializeSystems.push(cast system);
		return this;
	}

}