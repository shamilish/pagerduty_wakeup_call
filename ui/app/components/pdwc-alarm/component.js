import Ember from 'ember';

export default Ember.Component.extend({
  onStop: null,
  actions: {
    stop: function() {
      console.log('onStop');
      this.onStop();
    }
  }
});
