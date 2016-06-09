(function() {
  var FSM, exports;

  FSM = {};

  FSM.Machine = (function() {
    function Machine(context) {
      this.context = context;
      this._stateTransitions = {};
      this._stateTransitionsAny = {};
      this._defaultTransition = null;
      this._initialState = null;
      this._currentState = null;
    }

    Machine.prototype.addTransition = function(action, state, nextState, callback) {
      if (!nextState) {
        nextState = state;
      }
      return this._stateTransitions[[action, state]] = [nextState, callback];
    };

    Machine.prototype.addTransitions = function(actions, state, nextState, callback) {
      var action, _i, _len, _results;
      if (!nextState) {
        nextState = state;
      }
      _results = [];
      for (_i = 0, _len = actions.length; _i < _len; _i++) {
        action = actions[_i];
        _results.push(this.addTransition(action, state, nextState, callback));
      }
      return _results;
    };

    Machine.prototype.addTransitionAny = function(state, nextState, callback) {
      if (!nextState) {
        nextState = state;
      }
      return this._stateTransitionsAny[state] = [nextState, callback];
    };

    Machine.prototype.setDefaultTransition = function(state, callback) {
      return this._defaultTransition = [state, callback];
    };

    Machine.prototype.getTransition = function(action, state) {
      if (this._stateTransitions[[action, state]]) {
        return this._stateTransitions[[action, state]];
      } else if (this._stateTransitionsAny[state]) {
        return this._stateTransitionsAny[state];
      } else if (this._defaultTransition) {
        return this._defaultTransition;
      }
      throw new Error("Transition is undefined: (" + action + ", " + state + ")");
    };

    Machine.prototype.getCurrentState = function() {
      return this._currentState;
    };

    Machine.prototype.setInitialState = function(state) {
      this._initialState = state;
      if (!this._currentState) {
        return this.reset();
      }
    };

    Machine.prototype.reset = function() {
      return this._currentState = this._initialState;
    };

    Machine.prototype.process = function(action) {
      var result;
      result = this.getTransition(action, this._currentState);
      if (result[1]) {
        result[1].call(this.context || (this.context = this), action);
      }
      return this._currentState = result[0];
    };

    return Machine;

  })();

  if (typeof window !== 'undefined') {
    window.FSM = FSM;
  }

  if (typeof module !== 'undefined' && module.exports) {
    exports = module.exports = FSM;
  }

}).call(this);
