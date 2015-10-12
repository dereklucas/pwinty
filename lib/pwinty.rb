require "pwinty/version"
require "multipart"
require "rest_client"

module Pwinty

  def self.client(args={})
    @@client ||= Pwinty::Client.new(args)
    @@client
  end

  class Client
    attr_accessor :pwinty
    def initialize(args={})
      options = { merchant_id: ENV['PWINTY_MERCHANT_ID'], api_key: ENV['PWINTY_API_KEY'], production: ENV['PWINTY_PRODUCTION'] == 'true' }.merge(args)
      subdomain = options[:production] == true ? "api" : "sandbox"
      apiVersion = options[:api_version] || 'v2.1'
      domain = "https://#{subdomain}.pwinty.com/#{apiVersion}"

      @pwinty = RestClient::Resource.new(domain, :headers => {
        "X-Pwinty-MerchantId" => options[:merchant_id],
        "X-Pwinty-REST-API-Key" => options[:api_key],
        'Accept' => 'application/json'
      })
    end

    def catalog(countryCode: 'US', qualityLevel: 'Standard')
      JSON.parse @pwinty["/Catalogue/#{countryCode}/#{qualityLevel}"].get
    end

    # Orders
    def get_orders
      JSON.parse @pwinty["/Orders"].get
    end

    def create_order(**args)
      JSON.parse @pwinty["/Orders"].post(args)
    end

    def update_order(**args)
      JSON.parse @pwinty["/Orders/#{args[:id]}"].put(args)
    end

    # Order Status
    def get_order_status(id)
      JSON.parse @pwinty["/Orders/#{id}/SubmissionStatus"].get
    end

    def update_order_status(id, status)
      JSON.parse @pwinty["/Orders/#{id}/Status"].post(status: status)
    end

    # Order Photos
    def get_photos(orderId)
      JSON.parse @pwinty["/Orders/#{orderId}/Photos"].get
    end

    def get_photo(orderId, photoId)
      JSON.parse @pwinty["/Orders/#{orderId}/Photos/#{photoId}"].get
    end


    def add_photo(**args)
      headers = {}
      orderId = args.delete(:orderId)

      unless args[:file].nil?
        args, headers = Multipart::Post.prepare_query(args)
      end

      JSON.parse @pwinty["/Orders/#{orderId}/Photos"].post(args, headers)
    end

    def add_photos(orderId, photos)
      body = photos.is_a?(String) ? photos : photos.to_json
      JSON.parse @pwinty["/Orders/#{orderId}/Photos/Batch"].post(body, {'Content-Type' => 'application/json'} )
    end

    def delete_photo(orderId, photoId)
      JSON.parse @pwinty["/Orders/#{orderId}/Photos/#{photoId}"].delete
    end

    # Countries
    def countries
      JSON.parse @pwinty["/Country"].get
    end
  end
end
