require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Cannot double-render" if @already_built_response
    
    @res.body = content
    @res.content_type = type
    self.session.store_session(@res)
    
    @already_built_response = true
  end

  # helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # set the response status code and header
  def redirect_to(url)
    @res.status = 302
    @res.reason_phrase = "Found"
    @res["Location"] = (url =~ /http:\/\// ? "" : "http://") + url
    self.session.store_session(@res)
    
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = ERB.new(File.read("views/#{self.class.to_s.underscore}/#{template_name}.html.erb"))
    render_content(template.result(binding),"text/html")
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless self.already_built_response?
  end
end
