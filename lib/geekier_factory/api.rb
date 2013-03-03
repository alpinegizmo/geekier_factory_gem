require 'faraday'
require 'faraday_middleware'
require 'faraday_body_logger'

module GeekierFactory  
  class API
    def initialize(structure)
      @structure = structure
      @actions = @structure['apis'].map{ |api| api['operations'].map{ |op| Action.new(self, op.merge('path' => api['path'])) } }.flatten
    end

    def log_body?
      true
    end

    def api_connection
      @connection ||= begin
        Faraday.new(base_url, ssl: {verify: false}) do |builder|
          builder.request :json
          
          # builder.request :oauth, credentials_hash.merge(oauth_consumer_credentials) if oauth? and oauth_consumer_credentials.present?
          
          builder.response :body_logger if log_body?
          
          builder.adapter Faraday.default_adapter
        end
      end
    end
    
    def available_actions
      @actions
    end

    def base_url
      @structure['basePath'].end_with?('/') ? @structure['basePath'] : (@structure['basePath'] + '/')
    end
    
    def error_responses
      @structure['errorResponses'] || []
    end

    # def oauth?
    #   true
    # end
    # 
    # def oauth_consumer_credentials
    #   {:consumer_key => 'xxxx', :consumer_secret => 'xxxx'}
    # end
    # 
    # def consumer
    #   OAuth::Consumer.new(oauth_consumer_credentials[:consumer_key], oauth_consumer_credentials[:consumer_secret], :site => base_url)
    # end
  end
end