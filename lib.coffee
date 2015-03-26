addEvents = (view, component) ->
  for events in component.events()
    eventMap = {}

    for spec, handler of events
      do (spec, handler) ->
        eventMap[spec] = (args...) ->
          event = args[0]

          # We set view based on the current target so that inside event handlers
          # BlazeComponent.currentData() (and Blaze.getData() and Template.currentData())
          # returns data context of event target and not component/template.
          Blaze._withCurrentView Blaze.getView(event.currentTarget), ->
            handler.apply component, args

          # Make sure CoffeeScript does not return anything. Returning from event
          # handlers is deprecated.
          return

    Blaze._addEventMap view, eventMap

ignoreHelper = (methodName, method) ->
  return true unless _.isFunction method

  # Ignore life cycle methods and events map defined on the base class.
  methodName in ['onCreated', 'onRendered', 'onDestroyed', 'events']

helpers = (template, componentClass) ->
  helpers = {}

  for methodName, method of (componentClass::) when not ignoreHelper methodName, method
    do (methodName, method) ->
      helpers[methodName] = (args...) ->
        # TODO: Are we sure this always gives the template instance of this component? Even when it is called from the included template?
        templateInstance = Template.instance()
        # We re-read the method from the component to allow possible monkey-patching of the component.
        # But this allows only overriding existing methods, not adding new ones. They will not be
        # available as helpers.
        templateInstance.component[methodName] args...

  helpers

class BlazeComponent
  @template: (template) ->
    componentClass = @

    template = Template[template] if _.isString template

    template.onCreated ->
      # Set helpers the first time the template is created. This allows component
      # class to be completely defined instead of being partially defined if we
      # would set helpers directly from the @template call.
      template.helpers helpers template, componentClass unless template._componentHelpersAdded
      template._componentHelpersAdded = true

      @view._onViewRendered =>
        # Attach events the first time template instance renders.
        addEvents @view, @component if @view.renderCount is 1

      # @ is a template instance.
      @component = new componentClass()
      @component.templateInstance = @
      @component.onCreated()

    template.onRendered ->
      # @ is a template instance.
      @component.onRendered()

    template.onDestroyed ->
      # @ is a template instance.
      @component.onDestroyed()

  onCreated: ->

  onRendered: ->

  onDestroyed: ->

  events: ->
    []

  # Component-level data context. Reactive. Use this to always get the
  # top-level data context used to render the component.
  data: ->
    Blaze.getData @templateInstance.view

  # Caller-level data context. Reactive. Use this to get in event handlers the data
  # context at the place where event originated (target context). In template helpers
  # the data context where template helpers were called. In onCreated, onRendered,
  # or onDestroyed, the same as @data().
  currentData: ->
    Blaze.getData()

# We copy utility methods ($, findAll, autorun, subscribe, etc.) from the template instance prototype.
for methodName, method of Blaze.TemplateInstance::
  BlazeComponent::[methodName] = (args...) ->
    @templateInstance[methodName] args...