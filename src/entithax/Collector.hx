package entithax;

import entithax.Entity;
import entithax.Group;
import entithax.Component;
//import entithax.DelegateGroupChanged;

//import thx.HashSet;

/// A Collector can observe one or more groups from the same context
/// and collects changed entities based on the specified groupEvent.
class Collector {
	public var collectedEntities(default, null) = Entities.create();
	private var group_ : Group;
	private var groupEvent_: GroupEvent;
	
	public function new(group: Group, groupEvent: GroupEvent) {
		group_ = group;
		groupEvent_ = groupEvent;
		activate();
	}

	// Add entity to collector
	public function collectEntity(group: Group, entity: Entity, index: Int, component: Component) {
		collectedEntities.add(entity);
	}

    /// Activates the Collector and will start collecting
    /// changed entities. Collectors are activated by default.
	public function activate() {
		switch (groupEvent_) {
			case Added:  group_.onEntityAdded.addDelegate(0, collectEntity);
			case Removed: group_.onEntityRemoved.addDelegate(0, collectEntity);
			case AddedOrRemoved: {
				group_.onEntityAdded.addDelegate(0, collectEntity);
				group_.onEntityRemoved.addDelegate(0, collectEntity);
			} 
		}
	}

	public function deactivate() {
		//  TODO implement
	}

	public function clearCollected() {
		collectedEntities = collectedEntities.empty();
	}
}