import Ember from 'ember';
// import _ from 'bower_components/howler/howler';

const SOUNDS = [
  'bomb.mp3',
  'door.mp3',
  'fire_alarm.mp3',
  'fire_pager.mp3',
  'foghorn.mp3',
  'railroad.mp3',
  'tornado_1.mp3',
  'tornado_2.mp3'
];

export default Ember.Component.extend({
  onStop: null,
  currentSound: null,

  didInsertElement() {
    this.soundAlarm();
  },

  soundAlarm() {
    let sound = SOUNDS[Math.floor(Math.random() * SOUNDS.length)];
    let s = new Howl({
      src: sound,
      onend: () => this.soundAlarm()
    });
    this.set('currentSound', s);
    s.play();
  },

  stopAlarm() {
    this.get('currentSound').stop();
    this.set('currentSound', null);
  },

  playAllSounds(id) {
    id = id || 0;
    if (id < SOUNDS.length) {
      let s = new Howl({
        src: SOUNDS[id],
        onend: () => this.playAllSounds(id+1)
      });
      s.play();
    }
  },

  actions: {
    stop: function() {
      console.log('onStop');
      this.stopAlarm();
      this.get('onStop')();
    }
  }
});
