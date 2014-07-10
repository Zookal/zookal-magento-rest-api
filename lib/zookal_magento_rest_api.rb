require "zookal_magento_rest_api/version"

module ZookalMagentoRestApi
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
      response_status = response.code.to_i rescue nil
      response_message = response.message rescue nil
      # decode response body and rescue if there's a ParseError (e.g. when Magento returns HTML after invalid authentication)
      if response        
        begin
          response_body_decoded = MultiJson.decode(response.body)
        rescue MultiJson::ParseError => exception
          puts "MultiJson::ParseError"
          puts exception
          response_body_decoded = nil
        end
      else
        response_body_decoded = nil
      end
      response_o_auth_error_message = get_oauth_error_message(response_body_decoded)      

      attributes = get_book_attributes(response_body_decoded)
      entity_id = get_entity_id(attributes, response_body_decoded)

      attributes[:meta_status] = response_status if response_status
      attributes[:meta_message] = response_message if response_message
      errors = get_errors(opts, purchase_type_id, response_o_auth_error_message)      
      attributes[:meta_errors] = errors if errors
      
      attributes[:present?] = is_book_present?(attributes)
      url_with_params = get_url_with_params(attributes, entity_id)
      attributes[:url_with_params] = url_with_params if url_with_params

      OpenStruct.new(attributes)    
    end

  private

    def prepare_access_token
      consumer = OAuth::Consumer.new(ZookalMagentoRestApi.consumer_key, ZookalMagentoRestApi.consumer_secret, :site => ZookalMagentoRestApi.site)
      token_hash = {oauth_token: ZookalMagentoRestApi.access_key, oauth_token_secret: ZookalMagentoRestApi.access_secret}
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

    def get_oauth_error_message(response_body_decoded)
      response_body_decoded["messages"]["error"].first["message"] rescue nil
    end

    def get_book_attributes(response_body_decoded)
      sku = response_body_decoded.values.first["sku"] rescue nil
      sku ? response_body_decoded.values.first : {}
    end

    def get_entity_id(attributes, response_body_decoded)
      return nil unless attributes.any?
      response_body_decoded.keys.first
    end

    def get_errors(opts, purchase_type_id, response_o_auth_error_message)
      errors = []

      unless ZookalMagentoRestApi.consumer_key
        errors << "config.consumer_key not specified in initializer file"
      end

      unless ZookalMagentoRestApi.consumer_secret
        errors << "config.consumer_secret not specified in initializer file"
      end

      unless ZookalMagentoRestApi.site
        errors << "config.site not specified in initializer file"
      end

      unless ZookalMagentoRestApi.access_key
        errors << "config.access_key not specified in initializer file"
      end

      unless ZookalMagentoRestApi.access_secret
        errors << "config.access_secret not specified in initializer file"
      end                                          

      unless opts.has_key?(:isbn)
        errors << "Attribute isbn not specified"
      end

      unless opts.has_key?(:purchase_type)
        errors << "Attribute purchase_type not specified"
      end

      unless purchase_type_id
        errors << "Invalid value for attribute purchase_type"
      end

      if response_o_auth_error_message
        errors << response_o_auth_error_message
      end      

      errors.any? ? errors : nil
    end

    def is_book_present?(attributes)
      attributes["sku"] ? true : false
    end

    def get_url_with_params(attributes, entity_id)
      return nil unless ZookalMagentoRestApi.site && attributes["url_key"] && entity_id
      
      url = "#{ZookalMagentoRestApi.site}/catalog/product/view/id/#{entity_id}"
      if ZookalMagentoRestApi.url_params
        url = url + "?#{ZookalMagentoRestApi.url_params}"
      end
      
      url             
    end

  end
end
