package entithax;

import entithax.Component;
import entithax.Entity;
import entithax.Group;
import entithax.*;

import haxe.ds.GenericStack;
import haxe.ds.HashMap;

import de.polygonal.ds.tools.ObjectPool;

import thx.Tuple;

//typedef ComponentPool = GenericStack<Component>;
typedef ComponentPool = ObjectPool<Component>;
typedef ComponentPools = Array<ComponentPool>;
//typedef 

class Context {
	private var creationIndex_: Int = 0;
	private var totalComponents_: Int;
	private var componentPools_ = new ComponentPools();
	private var entities_ =  Entities.create();
	private var entitiesCache_: Array<Entity>;
	private var entitiesPool_ : ObjectPool<Entity>;
	private var dbgUsePool = true;

	private var groups_ = new HashMap<Matcher, Group>();
	private var groupsForIndex_ = new Array<List<Group>>();

	public function new(totalComponents: Int, startCreationIndex: Int ) {
		totalComponents_ = totalComponents;
		creationIndex_ = startCreationIndex;
		for (i in 0...totalComponents) {
			groupsForIndex_[i] = new List<Group>();
		}
		entitiesPool_ = new ObjectPool(createEntityNew);
	}
	public  function createEntityNew() : Entity {
		var entity = new Entity();
		entity.initialize(creationIndex_++, totalComponents_, componentPools_);
		entity.onComponentAdded = updateGroupsComponentAddedOrRemoved;
		entity.onComponentRemoved = updateGroupsComponentAddedOrRemoved;
		entity.onComponentReplaced = updateGroupsComponentReplaced;
		return entity;
	}

	public function createEntity() : Entity {
		// invalidate entitiesCache_
		entitiesCache_ = null;

		// TODO reuse

		//var entity = new Entity();
		//entity.initialize(creationIndex_++, totalComponents_, componentPools_);
		//entity.onComponentAdded = updateGroupsComponentAddedOrRemoved;
		//entity.onComponentRemoved = updateGroupsComponentAddedOrRemoved;
		//entity.onComponentReplaced = updateGroupsComponentReplaced;
		// TODO onEntityReleased implement
		var entity: Entity;
		if (dbgUsePool) 
			entity = entitiesPool_.get();
		else
			entity = createEntityNew();
		entity.reactivate(creationIndex_++);

		entities_.add(entity);
		return entity;
	}


	public function destroyEntity(entity: Entity) {
		var removed = entities_.remove(entity);
		if (!removed) {
			throw("Entity does not exist in this context.");
		}
		entitiesCache_ = null;

		entity.destroy();
		if (dbgUsePool)
			entitiesPool_.put(entity);
	}

	public function createCollector(matcher: Matcher, event : GroupEvent /*= GroupEvent.Added*/) : Collector {
		var g = getGroup(matcher);
		return new Collector(g, event);
	}

	// Returns a group for the specified matcher.
	public function getGroup(matcher: Matcher) : Group {
		var group = groups_.get(matcher);
		if (group == null) {
			group = new Group(matcher);
			// 'Handle' all entities that are already in a context
			// Thus if the group is created later it will still be able to 'handle'
			// previously created entities
			for (e in getEntities()) {
				group.handleEntitySilently(e);
			}
			groups_.set(matcher, group);

			var allIndices = matcher.allIndices();
			for (i in allIndices) {
				groupsForIndex_[i].add(group);
			}
			// TODO call onGroupCreated
		}
		return group;
	}

	public function getEntities(): Array<Entity> {
		if (entitiesCache_ == null) {
			entitiesCache_ = entities_.toArray();
		}
		return entitiesCache_;
	}

	public function updateGroupsComponentAddedOrRemoved(entity: Entity, index: Int, component: Component) {
		var groups = groupsForIndex_[index];
		var callbacks = new List<Tuple2<Group, DelegateGroupChanged>>();
		for (g in groups) {
			var cb = g.handleEntity(entity);
			if (cb != null)
				callbacks.add(new Tuple2(g, cb));
		}
		for (cbt in callbacks) {
			cbt._1.invoke(cbt._0, entity, index, component);
		}
	}

	public function updateGroupsComponentReplaced(entity: Entity, index: Int, previousComponent: Component, newComponent: Component) {
		//trace("NotImplemented");
		var groups = groupsForIndex_[index];
		for (g in groups) {
			g.updateEntity(entity, index, previousComponent, newComponent);			
		}
	}
}