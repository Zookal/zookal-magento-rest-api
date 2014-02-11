# MagentoRestApi

Ruby wrapper for backend Magento REST API calls. Prior authentication & authorization (through oAuth) required.

## Installation

Add this line to your application's Gemfile:

    gem 'magento_rest_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magento_rest_api

## Setup

Create a file `config/magento_rest_api.rb` with the following content:

    MagentoRestApi.configure do |config|
      config.consumer_key = "123dsfdsafQ231"                                                      # from Magento Admin panel
      config.consumer_secret = "23dfsfFdsfsdee"                                                   # from Magento Admin panel
      config.site = "https://www.zookal.com"                                                      # without trailing slash and no redirects (e.g. root domain to www)
      config.access_key = "3434412373rf"                                                          # from prior authentication
      config.access_secret = "df23sdfsf23a"                                                       # from prior authentication
      config.url_params = "utm_source=booko&utm_medium=affiliate&utm_campaign=semester-1-2014"    # optional
    end

*Important*: Make sure the URL in the site configuration is without trailing slash and has no redirect (e.g. `https://zookal.com` redirects to `https://www.zookal.com`)
Information on how to obtain access_key and access_secret can be obtained [here](https://github.com/necrodome/magento-rails-rest-access-sample/blob/master/app/controllers/products_controller.rb)

## Usage

Instantiate a client:

    magento_client = MagentoRestApi::Client.new

Query a book

    book_buy_new = magento_client.find_by(isbn: 9781442531109, purchase_type: "Buy New")
    book_rent = magento_client.find_by(isbn: 9781442531109, purchase_type: "Rent")

Check if a book exists

    book_buy_new.exists?

Get price

    book_buy_new.special_price

Get 

Get other attributes
    
    book_buy_new.price # RRP
    book_buy_new.author # author
    book_buy_new.sku # SKU
    book_buy_new.name # Name
    book_buy_new.edition # Edition
    book_buy_new.publisher # Publisher
    book_buy_new.year # Year
    book_buy_new.pages # Year
    


## Contributing

1. Fork it ( http://github.com/<my-github-username>/magento_rest_api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
