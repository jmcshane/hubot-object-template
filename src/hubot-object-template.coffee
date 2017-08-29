# Description:
#   Hubot yaml/JSON object templating engine
#
# Commands:
#   template init [TEMPLATE_NAME] - create a new template
#   template search [search string] - search existing templates
#   template describe [TEMPLATE_NAME] - output template Information
#   template remove [TEMPLATE_NAME] - delete template
#   template [TEMPLATE_NAME] add property [PROPERTY NAME],[PROPERTY VALUE]
#   template [TEMPLATE_NAME] add parameter [PARAMETER NAME],[PARAMETER TYPE -> string, numeric, or date]
#   template parameter types
#   template
# Author:
#   @jmcshane
Path = require 'path'
Template = require(Path.join(__dirname, "..", "lib", "Template"))
TEMPLATE_STORAGE_KEY = "object-template-storage"

class ObjectTemplate

  # Initialize the change template library
  # robot - A Robot instance.
  constructor : (@robot) ->
    @_configureRobot()
    @robot.brain.on 'loaded', =>
      @_loadData()

  _loadData : () ->
    templates = @robot.brain.get TEMPLATE_STORAGE_KEY
    if !@config
      @config = {}
    for key, value of templates
      @config[key] = new Template(value.metadata, value.properties, value.parameters)

  _initTemplate: (msg) ->
    userName = msg.message.user.name
    templateName = msg.match[1]
    err = @initTemplate userName, templateName, msg.message.room
    if err
      msg.reply """Template #{templateName} already exists.
Use templates search [NAME] to see if a template name is available"""
    else
      msg.reply "Template #{templateName} created"

  initTemplate: (templateName ,userName, roomName) ->
    if @config.hasOwnProperty templateName
      return 0
    @config[templateName] = Template.init templateName, userName, roomName
    @_update()
    return 1

  _getTemplate: (msg) ->
    templateName = msg.match[1]
    resp = @getTemplate templateName
    if resp.error
      msg.reply resp.error
    else
      msg.reply resp.toString()

  getTemplate: (templateName) ->
    if !@config.hasOwnProperty templateName
      return error: """This template does not exist.
Use templates search [NAME] to locate existing templates"""
    return @config[templateName]

  _searchTemplates: (msg) ->
    searchString = msg.match[1].trim()
    locatedTemplates = []
    for k,v in @config
      if k.contains searchString
        locatedTemplates << k
    if locatedTemplates.length
      msg.reply locatedTemplates.join("\n")
    else
      msg.reply "No templates found"

  _removeTemplate: (msg) ->
    templateName = msg.match[1]
    if !@config.hasOwnProperty templateName
      msg.reply """This template does not exist.
Use templates search [NAME] to locate existing templates"""
      return
    delete @config[templateName]
    msg.reply "Template #{templateName} deleted"
    @_update()

  _addTemplateValue: (msg) ->
    template = @getTemplate(msg.match[1])
    if template.error
      msg.reply template.error
      return
    resp = @_addTemplateValue(template, msg.match[2].toLowerCase(), msg.match[3].trim(), msg.match[4].trim())
    if resp && resp.error
      msg.reply resp.error
    else
      msg.reply "Template #{template.metadata.name} updated"

  _addTemplateValue: (template, type, key, value) ->
    if type == "property"
      template.addProperty(key, value)
    else
      if Template.validParameterTypes().indexOf(value) > -1
        template.addParameter(key, value)
      else
        return error: "Invalid parameter type, must be one of #{Template.validParameterTypes()}"
    @_update

  _update: ->
    @robot.brain.set TEMPLATE_STORAGE_KEY, @config

  _configureRobot: ->
    @robot.respond /template init (.+)/i, (msg) =>
      @_initTemplate msg
    @robot.respond /template describe (.+)/i, (msg) =>
      @_getTemplate msg
    @robot.respond /template search(.*)/i, (msg) =>
      @_searchTemplates msg
    @robot.respond /template remove (.+)/i, (msg) =>
      @_removeTemplate msg
    @robot.respond /template (.+) add (property|parameter) ([^,]+),(.*)/, (msg) =>
      @_addTemplateValue msg
    @robot.template = @

module.exports = (robot) ->
  new ObjectTemplate robot
