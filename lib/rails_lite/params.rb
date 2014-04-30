require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(req, route_params = {})
    @params = route_params
    @params.merge! parse_www_encoded_form(req.query_string) if req.query_string
    @params.merge! parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    @params[key.to_sym]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_json
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    temp = {}
    URI.decode_www_form(www_encoded_form).each do |pair|
      p pair
      p temp
      # temp[pair.first] = pair.last
      keys = parse_key(pair.first)
      prev_key = temp
      keys.each do |key|
        if key == keys.last
          prev_key[key] = pair.last
        else
          prev_key[key] ||= Hash.new
          prev_key = prev_key[key]
        end
      end
    end
    temp
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
