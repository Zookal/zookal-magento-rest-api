require "spec_helper"

describe MagentoRestApi::Client do  
  response_body_book_buy_new = "{\"2378\":{\"status\":\"1\", \"sku\":\"978123432423\", \"url_key\":\"marketing-and-the-law\"}}"
  response_body_unauthorized = "{\"messages\":{\"error\":[{\"code\":401,\"message\":\"oauth_problem=consumer_key_rejected\"}]}}"
  after(:each) do
    reset_class_variables MagentoRestApi
  end

  context "when a configuration attribute is missing in the initializer file" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = nil
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 401,
                      :body => response_body_unauthorized
                      )
      book = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(book.meta_status).to eq 401
      expect(book.meta_errors.count).to eq 2
      expect(book.meta_errors.first).to eq "config.consumer_key not specified in initializer file"
      expect(book.present?).to be_false
    end
  end

  context "when two configuration attributes are missing in the initializer file" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = nil
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = nil
      MagentoRestApi.access_secret = "secret"

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 401,
                      :body => response_body_unauthorized
                      )
      book = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(book.meta_status).to eq 401
      expect(book.meta_errors.count).to eq 3
      expect(book.meta_errors[0]).to eq "config.consumer_key not specified in initializer file"
      expect(book.meta_errors[1]).to eq "config.access_key not specified in initializer file"
      expect(book.present?).to be_false      
    end
  end

  context "when no book was found" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = "key"
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => "[]"
                      )
      book = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(book.meta_status).to eq 200
      expect(book.meta_errors).to be_nil
      expect(book.special_price).to be_nil
      expect(book.present?).to be_false
    end
  end  

  context "when purchase_type was not specified" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = "key"
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      book = magento_client.find_by(isbn: 123)
      expect(book.meta_status).to eq 200
      expect(book.meta_errors.count).to eq 2      
      expect(book.meta_errors[0]).to eq "Attribute purchase_type not specified"
      expect(book.present?).to be_true      
    end
  end

  context "when isbn was not specified" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = "key"
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      book = magento_client.find_by(purchase_type: "Buy New")
      expect(book.meta_status).to eq 200
      expect(book.meta_errors.count).to eq 1
      expect(book.meta_errors[0]).to eq "Attribute isbn not specified"      
      expect(book.present?).to be_true      
    end
  end

  context "when invalid purchase_type was entered" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = "key"
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      book = magento_client.find_by(isbn: 123, purchase_type: "Bbla")
      expect(book.meta_status).to eq 200
      expect(book.meta_errors.count).to eq 1
      expect(book.meta_errors.first).to eq "Invalid value for attribute purchase_type"
      expect(book.present?).to be_true            
    end
  end

  context "when requested book was found and no url params exists" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = "key"
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"
      MagentoRestApi.url_params = nil

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      book = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(book.meta_status).to eq 200
      expect(book.meta_errors).to be_nil
      expect(book.present?).to be_true
      expect(book.url_with_params).to eq "https://www.zookal.com/catalog/product/view/id/2378"
    end
  end

  context "when requested book was found and url params exists" do            
    it "set the correct attributes" do
      MagentoRestApi.consumer_key = "key"
      MagentoRestApi.consumer_secret = "secret"
      MagentoRestApi.site = "https://www.zookal.com"    
      MagentoRestApi.access_key = "key"
      MagentoRestApi.access_secret = "secret"
      MagentoRestApi.url_params = "utm_source=company&utm_medium=affiliate&utm_campaign=2014"      

      magento_client = MagentoRestApi::Client.new

      WebMock.stub_request(:get, "https://www.zookal.com/api/rest/products?filter[1][attribute]=isbn&filter[1][eq]=123&filter[2][attribute]=purchase_type&filter[2][eq]=56&filter[3][attribute]=status&filter[3][eq]=1")
           .to_return(:status => 200,
                      :body => response_body_book_buy_new
                      )
      book = magento_client.find_by(isbn: 123, purchase_type: "Buy New")
      expect(book.meta_status).to eq 200
      expect(book.meta_errors).to be_nil
      expect(book.present?).to be_true
      expect(book.url_with_params).to eq "https://www.zookal.com/catalog/product/view/id/2378?utm_source=company&utm_medium=affiliate&utm_campaign=2014"
    end
  end                   
end