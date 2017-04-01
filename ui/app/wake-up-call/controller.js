import Ember from 'ember';

const { Controller } = Ember;

const API_ENDPOINT = "http://localhost:4000/incidents";
const POLL_INTERVAL = 1000;

export default Controller.extend({
  triggered: false,
  incidents: null,
  requestService: Ember.inject.service('ajax'),

  init() {
    this._super(...arguments);
    this.refreshIncidents();
  },

  refreshIncidents() {
    if (this.get('triggered') === false) {
      this.getIncidents()
      .then(resp => {
        this.updateState(resp.incidents);
        setTimeout(() => this.refreshIncidents(), POLL_INTERVAL);
      })
      .catch(err => {
        console.log("Error fetching incidents");
        console.log(err);
        setTimeout(() => this.refreshIncidents(), POLL_INTERVAL);
      });
    } else {
      setTimeout(() => this.refreshIncidents(), POLL_INTERVAL);
    }
  },

  getIncidents() {
    return this.get('requestService').request(API_ENDPOINT, {method: 'GET'});
  },

  updateState(newIncidents) {
    if (this.get('incidents') != null && newIncidents.length > this.get('incidents').length) {
      this.set('triggered', true);
    }
    this.set('incidents', newIncidents);
  },

  actions: {
    reset: function() {
      this.set('triggered', false);
    }
  }

});
