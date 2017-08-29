NAME = "Name"
TYPE = "Parameter Type"
class Template
  constructor: (@metadata, @props, @parameters) ->
    if !@props
      @props = {}
    if !@parameters
      @parameters = {}

  @init: (templateName, userName, roomName) ->
    metadata =
      Name: templateName
      Creator : userName
      "Create Date" : new Date()
      Room: roomName
    props = {}
    parameters = {}
    return new Template(metadata, props, parameters)

  addProperty: (key, value) ->
    @props[key] = value

  addParameter: (name, type) ->
    @parameters[NAME] = key
    @parameters[TYPE] = type

  @validParameterTypes : ->
    ["string", "numeric", "date"]

  toString: ->
    output = @_loopingString @metadata, "Template Information:"
    output += @_loopingString @props, "\nTemplate Properties:"
    output += @_loopingString @parameters, "\nTemplate Parameters:"
    return output

  _loopingString: (obj, initializer) ->
    output = initializer
    for own key, value of obj
      output += "\n\t#{key}: #{value}"
    return output

module.exports = Template
