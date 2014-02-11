require "spec_helper"

describe MagentoRestAPI::Client do  
  response_body_book_buy_new = "{\"2378\":{\"status\":\"1\", \"sku\":\"978123432423\"}}"
  response_body_unauthorized = "{\"messages\":{\"error\":[{\"code\":401,\"message\":\"oauth_problem=consumer_key_rejected\"}]}}"
  after(:each) do
    reset_class_variables MagentoRestAPI
  end

  context "when a configuration attribute is missing in the initializer file" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = nil
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"
      MagentoRestAPI.access_key = "key"
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 401,
                      :body => response_body_unauthorized
                      )
      response = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(response.status).to eq 401
      expect(response.errors.count).to eq 2
      expect(response.errors.first).to eq "config.consumer_key not specified in initializer file"
    end
  end

  context "when two configuration attributes are missing in the initializer file" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = nil
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"    
      MagentoRestAPI.access_key = nil
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 401,
                      :body => response_body_unauthorized
                      )
      response = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(response.status).to eq 401
      expect(response.errors.count).to eq 3
      expect(response.errors[0]).to eq "config.consumer_key not specified in initializer file"
      expect(response.errors[1]).to eq "config.access_key not specified in initializer file"
    end
  end

  context "when no book was found" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = "key"
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"    
      MagentoRestAPI.access_key = "key"
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => "[]"
                      )
      response = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(response.status).to eq 200
      expect(response.errors).to be_nil
      expect(response.special_price).to be_nil
      expect(response.exists?).to be_false
    end
  end  

  context "when purchase_type was not specified" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = "key"
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"    
      MagentoRestAPI.access_key = "key"
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      response = magento_client.find_by(isbn: 123)
      expect(response.status).to eq 200
      expect(response.errors.count).to eq 2      
    end
  end

  context "when isbn was not specified" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = "key"
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"    
      MagentoRestAPI.access_key = "key"
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      response = magento_client.find_by(purchase_type: "Buy New")
      expect(response.status).to eq 200
      expect(response.errors.count).to eq 1      
    end
  end

  context "when invalid purchase_type was entered" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = "key"
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"    
      MagentoRestAPI.access_key = "key"
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      response = magento_client.find_by(isbn: 123, purchase_type: "Bbla")
      expect(response.status).to eq 200
      expect(response.errors.count).to eq 1
      expect(response.errors.first).to eq "Invalid value for attribute purchase_type"
    end
  end

  context "when book was returned" do            
    it "should mention the error in the response" do
      MagentoRestAPI.consumer_key = "key"
      MagentoRestAPI.consumer_secret = "secret"
      MagentoRestAPI.site = "https://www.zookal.com"    
      MagentoRestAPI.access_key = "key"
      MagentoRestAPI.access_secret = "secret"

      magento_client = MagentoRestAPI::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      response = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(response.status).to eq 200
      expect(response.errors).to be_nil
      expect(response.exists?).to be_true
    end
  end           
end