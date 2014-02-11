require "magento_rest_api/version"

module MagentoRestAPI
  class << self
    attr_accessor :consumer_key, :consumer_secret, :site, :access_key, :access_secret
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
          attributes = MultiJson.decode(response.body)
          attributes = attributes[attributes.keys.first] 
        end
      else
        attributes = {}
      end

      meta = prepare_meta_information(attributes, opts, purchase_type_id, response)
      attributes[:status] = meta[:status]
      attributes[:message] = meta[:message]
      attributes[:errors] = meta[:errors]
      attributes[:exists?] = meta[:exists?]

      OpenStruct.new(attributes)    
    end

  private

    def prepare_access_token
      consumer = OAuth::Consumer.new(MagentoRestAPI.consumer_key, MagentoRestAPI.consumer_secret, :site => MagentoRestAPI.site)
      token_hash = {oauth_token: MagentoRestAPI.access_key, oauth_token_secret: MagentoRestAPI.access_secret}
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

    def prepare_meta_information(attributes, opts, purchase_type_id, response)
      meta = {}

      unless MagentoRestAPI.consumer_key
        meta[:errors] ||= []
        meta[:errors] << "config.consumer_key not specified in initializer file"
      end

      unless MagentoRestAPI.consumer_secret
        meta[:errors] ||= []
        meta[:errors] << "config.consumer_secret not specified in initializer file"
      end

      unless MagentoRestAPI.site
        meta[:errors] ||= []
        meta[:errors] << "config.site not specified in initializer file"
      end

      unless MagentoRestAPI.access_key
        meta[:errors] ||= []
        meta[:errors] << "config.access_key not specified in initializer file"
      end

      unless MagentoRestAPI.access_secret
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

      meta[:exists?] = attributes["sku"] ? true : false

      meta
    end
  end
end
