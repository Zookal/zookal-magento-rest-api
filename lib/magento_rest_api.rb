require "magento_rest_api/version"

module MagentoRestApi
  class << self
    attr_accessor :consumer_key, :consumer_secret, :site, :access_key, :access_secret, :url_params
  end

  def self.configure(&block)
    yield self
  end  

  class Client
    require "oauth"
    require "multi_json"
    require "ostruct"

    def find_by(opts)
      @access_token ||= prepare_access_token       
      purchase_type_id = translate_purchase_type_to_purchase_type_id(opts[:purchase_type])      
      
      # rescue in case a configuration setting is missing, which will crash OAuth
      response = @access_token.get("/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=#{opts[:isbn]}&filter[2][attribute]=purchase_type&filter[2][eq]=#{purchase_type_id}&filter[3][attribute]=status&filter[3][eq]=1") rescue nil
      if response
        if response.body == "[]" || response.code.to_i != 200
          attributes = {}
        else
          decoded_response_body = MultiJson.decode(response.body)
          attributes = decoded_response[decoded_response_body.keys.first] 
        end
      else
        attributes = {}
      end

      meta_attributes = prepare_meta_attributes(attributes, opts, purchase_type_id, response)
      attributes[:status] = meta_attributes[:status]
      attributes[:message] = meta_attributes[:message]
      attributes[:errors] = meta_attributes[:errors]
      
      additional_attributes = prepare_additional_attributes(attributes, decoded_response_body.keys.first)
      attributes[:exists?] = additional_attributes[:exists?]
      attributes[:url_with_params] = additional_attributes[:url_with_params]

      OpenStruct.new(attributes)    
    end

  private

    def prepare_access_token
      consumer = OAuth::Consumer.new(MagentoRestApi.consumer_key, MagentoRestApi.consumer_secret, :site => MagentoRestApi.site)
      token_hash = {oauth_token: MagentoRestApi.access_key, oauth_token_secret: MagentoRestApi.access_secret}
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
    end

    def translate_purchase_type_to_purchase_type_id(purchase_type)
      return nil unless purchase_type.is_a? String
      case purchase_type.downcase
        when "buy new" then 56
        when "rent" then 55        
        else return nil
      end
    end

    def prepare_additional_attributes(attributes, entity_id)
      additional = {}

      additional[:exists?] = attributes["sku"] ? true : false

      if attributes["url_key"]
        additional[:url_with_params] = "#{MagentoRestApi.site}/#{attributes["url_key"]}-#{entity_id}.html"
        if MagentoRestApi.url_params
          additional[:url_with_params] = additional[:url_with_params] + "?#{MagentoRestApi.url_params}"
        end
      end             
    end


    def prepare_meta_attributes(attributes, opts, purchase_type_id, response)
      meta = {}

      unless MagentoRestApi.consumer_key
        meta[:errors] ||= []
        meta[:errors] << "config.consumer_key not specified in initializer file"
      end

      unless MagentoRestApi.consumer_secret
        meta[:errors] ||= []
        meta[:errors] << "config.consumer_secret not specified in initializer file"
      end

      unless MagentoRestApi.site
        meta[:errors] ||= []
        meta[:errors] << "config.site not specified in initializer file"
      end

      unless MagentoRestApi.access_key
        meta[:errors] ||= []
        meta[:errors] << "config.access_key not specified in initializer file"
      end

      unless MagentoRestApi.access_secret
        meta[:errors] ||= []
        meta[:errors] << "config.access_secret not specified in initializer file"
      end                                          

      unless opts.has_key?(:isbn)
        meta[:errors] ||= []
        meta[:errors] << "Attribute isbn not specified"
      end

      unless opts.has_key?(:purchase_type)
        meta[:errors] ||= []
        meta[:errors] << "Attribute purchase_type not specified"
      end

      unless purchase_type_id
        meta[:errors] ||= []
        meta[:errors] << "Invalid value for attribute purchase_type"
      end

      if response
        # convert status & message
        meta[:status] = response.code.to_i
        meta[:message] = response.message
        
        # copy HTTP message to error arrray
        unless meta[:status] == 200
          meta[:errors] ||= []
          meta[:errors] << meta[:message]
        end
      end      

      meta
    end
  end
end
