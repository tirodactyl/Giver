require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @cookie_name = '_rails_lite_app'
    req_cookie = req.cookies.select { |cookie| cookie.name == @cookie_name}
    @cookie_content = (req_cookie.empty? ? {} : JSON.parse(req_cookie.first.value))
  end

  def [](key)
    @cookie_content[key]
  end

  def []=(key, val)
    @cookie_content[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.cookies << WEBrick::Cookie.new(@cookie_name, @cookie_content.to_json)
  end
end
