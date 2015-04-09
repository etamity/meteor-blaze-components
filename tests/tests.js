var ExampleComponent = BlazeComponent.extendComponent({
  template: function () {
    return 'ExampleComponent';
  },

  onCreated: function () {
    this.counter = new ReactiveVar(0);
  },

  events: function () {
    return [{
      'click .increment': this.onClick
    }];
  },

  onClick: function (event) {
    this.counter.set(this.counter.get() + 1);
  },

  customHelper: function () {
    if (this.counter.get() > 10) {
      return "Too many times";
    }
    else if (this.counter.get() === 10) {
      return "Just enough";
    }
    else {
      return "Click more";
    }
  }
// We use ExampleComponentJS here for JavaScript implementation.
}).register('ExampleComponentJS');

var OurComponent = BlazeComponent.getComponent('MyComponent').extendComponent({
  values: function () {
    return '>>>' + OurComponent.__super__.values.call(this) + '<<<';
  }
}).register('OurComponent');
