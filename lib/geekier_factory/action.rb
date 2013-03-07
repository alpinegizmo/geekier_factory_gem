module GeekierFactory  
  class Action
    AttributesMissing = Class.new(Exception)
    ValidationException = Class.new(Exception)

    def initialize(api, structure)
      @api = api
      @structure = structure
    end
    
    def params
      @structure['parameters']
    end
    
    def body_params
      params.select{ |p| p['paramType'] == 'body' }
    end

    def path_params
      params.select{ |p| p['paramType'] == 'path' }
    end

    def url_params
      params.select{ |p| p['paramType'] == 'query' }
    end

    def url_hash(param_values)
      names = url_params.map{ |p| p['name'] }
      param_values.select{ |k,v| names.include?(k.to_s) }
    end

    def body_hash(param_values)
      names = body_params.map{ |p| p['name'] }
      param_values.select{ |k,v| names.include?(k.to_s) }
    end

    def path_hash(param_values)
      names = path_params.map{ |p| p['name'] }
      param_values.select{ |k,v| names.include?(k.to_s) }
    end

    def build_url(param_values)
      vals = path_hash(param_values)
      if (as = (path_variables - vals.keys.map(&:to_s))).any?
        raise AttributesMissing.new(as)
      end
      p = path
      vals.each do |k, v|
        p = p.sub("{#{k}}", v)
      end
      api_connection.build_url(p, url_hash(param_values))
    end

    def build_body(param_values)
      body_hash(param_values)
    end

    def http_method
      @structure['httpMethod']
    end
    
    def path
      @structure['path'].start_with?('/') ? @structure['path'][1..-1] : @structure['path']
    end
    
    def path_variables
      path.scan(/\{(\w*)\}/).flatten
    end

    def request_hash(param_values)
      { 
        :verb => http_method.downcase.to_sym,
        :url => build_url(param_values),
        :body => build_body(param_values)
      }
    end
    
    def api_connection
      @api.api_connection
    end

    def call(param_values = {})
      validate_parameter_values(param_values)
      reqhash = request_hash(param_values)
      response = api_connection.run_request(reqhash[:verb], reqhash[:url], reqhash[:body], reqhash[:headers])
      handle_response!(response)
      {:request => reqhash, :response => response}
    rescue Retry => e
      sleep 0.5
      retry
    end
    
    def validate_parameter_values(param_values)
      errors = Hash.new { |hash,key|hash[key] = [] }

      param_values.each do |k,v|
        parameter = params.detect{|p| p['name'] == k.to_s}

        errors[k] << "expected to be #{parameter['dataType']} (was #{p.class})" unless case parameter['dataType']
                                                                                       when 'byte'
                                                                                         true
                                                                                       when 'string'
                                                                                         v.is_a?(String)
                                                                                       when 'boolean'
                                                                                         v.is_a?(TrueClass) ||
                                                                                         v.is_a?(FalseClass)
                                                                                       when 'int'
                                                                                         v.is_a?(Integer)
                                                                                       when 'float'
                                                                                         v.is_a?(Float)
                                                                                       when 'double'
                                                                                         v.is_a?(Double)
                                                                                       when 'Date'
                                                                                         (v.is_a?(Date) || Date.parse(v)) rescue false
                                                                                       end

        if parameter.has_key?('allowableValues')
          vals = case parameter['allowableValues']['valueType']
          when 'RANGE'
            Range.new(parameter['allowableValues']['min'].to_i, parameter['allowableValues']['max'].to_i)
          when 'LIST'
            parameter['allowableValues']['values']
          end
          errors[k] << "expected to be one of #{vals}" unless vals.include?(v)
        end
      end

      if errors.any?
        raise ValidationException.new(errors.inspect)
      end
    end
    
    def error_responses
      (@structure['errorResponses'] || []) + @api.error_responses
    end

    Retry = Class.new(Exception)
    ConnectionException = Class.new(Exception)
    def handle_response!(response)
      if error_responses.map{ |er| er['code'] }.include? response.status
        ex = error_responses.find{ |er| er['code'] == response.status }
        if ex.has_key?('retry') && (@retries ||= 0) < ex['retry'].to_i
          @retries += 1
          raise Retry.new
        else
          message = "#{ex['reason']} (HTTP status code #{ex['code']})"
          message = message + "\n\n" + response[:body] if ex['details'] && ex['details'] == 'body'
          raise ConnectionException.new(message)
        end
      elsif !response.success?
        raise ConnectionException.new
      end
    end
  end
end