import Ember from 'ember';

const { Controller } = Ember;

const API_ENDPOINT = "http://localhost:4000/incidents";
const POLL_INTERVAL = 5000;

export default Controller.extend({
  triggered: false,
  incidents: [],
  requestService: Ember.inject.service('ajax'),

  init() {
    this._super(...arguments);
    this.refreshIncidents();
  },

  refreshIncidents() {
    this.getIncidents()
    .then(incidents => {
      console.log(incidents);
      this.set('incidents', incidents);
      setTimeout(() => this.refreshIncidents(), POLL_INTERVAL);
    })
    .catch(err => {
      console.log("Error fetching incidents");
      console.log(err);
      setTimeout(() => this.refreshIncidents(), POLL_INTERVAL);
    });
  },

  getIncidents() {
    return this.get('requestService').request(API_ENDPOINT, {method: 'GET'});
  }

});
