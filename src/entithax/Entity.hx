package entithax;

import entithax.Component;
import entithax.Context;
//import thx.Either;
//import thx.Arrays;
using thx.Arrays;
import thx.HashSet;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.ExprTools;
#end

import haxe.ds.Vector;

import entithax.detail.Macro;

typedef EntityComponentChanged = Entity -> Int -> Component -> Void;
typedef EntityComponentReplaced = Entity -> Int -> Component -> Component -> Void;


typedef Components = Vector<Component>;




class Entity  {
    // The context manages the state of an entity.
    // Active entities are enabled, destroyed entities are not.
	public var enabled(default, null): Bool;

	public var onComponentAdded: EntityComponentChanged;
	public var onComponentRemoved: EntityComponentChanged;
	public var onComponentReplaced: EntityComponentReplaced;

	//private var components = new Components();
	private var components : Components;
	//private var componentsCache: Components;
	private var componentPools_: ComponentPools;

	private var creationIndex_: Int;
	private var totalComponents_: Int;

	public function new() {

	}

	// This is required for hash map
    public function hashCode():Int
    {
        return creationIndex_;
    }

	public function toString() {
		return '$creationIndex_';
	}

	public function initialize(creationIndex: Int, totalComponents: Int, componentPools: ComponentPools) : Void {
		enabled = true;
		creationIndex_ = creationIndex;
		totalComponents_ = totalComponents;
		componentPools_ = componentPools;
		components = new Components(totalComponents);
	}
	
	inline private function enabledThrow() {
		if (!enabled) {
			throw("Entity is disabled!");
		}
	}

	public function reactivate(index: Int) {
		creationIndex_ = index;
		enabled = true;
	}

	/// Adds a component at the specified index.
	/// You can only have one component at an index.
	/// Each component type must have its own constant index.
	/// The prefered way is to use 'add' macro
	inline public function addComponent(index: Int,  component: Component): Void {
		#if debug
		enabledThrow();
		//trace('Adding component: ${index}');
		#end
		components[index] = component;
		if (onComponentAdded != null) {
			onComponentAdded(this, index, component);
		}
		#if debug
		else {
			trace('voila!');
		}
		#end
	}


	inline private function replaceImpl(index: Int, component: Component) {
		// TODO assert component exists
		var previousComponent = getComponent(index);
		if (previousComponent == component) {
			// just call back
			onComponentReplaced(this, index, previousComponent, component);
		}
		else {
			// add previous component to component ComponentPool
			components[index] = component;
			if (component != null) {
				onComponentReplaced(this, index, previousComponent, component);
			}
			else {
				// REMOVE
				//_componentIndicesCache
				if (onComponentRemoved != null)
					onComponentRemoved(this, index, previousComponent);
			}
		}
	}

	public function replaceComponent(index: Int, component: Component) {
		enabledThrow();
		if (hasComponent(index)) {
			replaceImpl(index, component);
		} else {
			addComponent(index, component);
		}
		return this;
	}

	public macro function replace(self: Expr, object: ExprOf<Component>) : Expr {
		var componentId = macro entithax.detail.Macro.getComponentId($object);
		return macro $self.replaceComponent($componentId, $object);
	}

    public macro function add(self:Expr, object:ExprOf<Component>): Expr {
		var componentId = macro entithax.detail.Macro.getComponentId($object);
		trace(componentId);
		return macro $self.addComponent($componentId, $object);
    }

    macro public function get<A:Component> (self: Expr, componentClass: ExprOf<Class<A>>): ExprOf<A>
    {
		var componentId = macro $componentClass.id_;
		return macro cast $self.getComponent($componentClass.id_);
    }

	inline public function getComponent(index: Int) : Component {
		return components[index];
	}


    // Determines whether this entity has a component
    // at the specified index.
	public inline function hasComponent(index: Int): Bool {
		return components[index] != null;
	}

    // Determines whether this entity has a component
    // at all of the specified indices.
	public function hasComponents(indices: ComponentIdArray): Bool {
		for (i in indices) {
			if (components[i] == null) {
				return false;
			}
		}
		return true;
	}
    
	// Determines whether this entity has a component
    // at any of the specified indices.
	public function hasAnyComponent(indices: ComponentIdArray) {
		//return indices.any(function(i) return components[i] != null);
		return indices.any(this.hasComponent);
	}

	private function removeAllComponents() {
		for (i in 0...components.length) {
			if (hasComponent(i)) {
				replaceImpl(i, null);
			}
		}
	}

	public function destroy() {
		removeAllComponents();
		//onComponentAdded = null;
		//onComponentRemoved = null;
		//onComponentReplaced = null;
		enabled = false;
		// TODO
	}

}

typedef Entities =  HashSet<Entity>;

