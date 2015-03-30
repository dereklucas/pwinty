require "pwinty/version"
require "multipart"
require "rest_client"

module Pwinty

  def self.client
    @@client ||= Pwinty::Client.new
    @@client
  end

  class Client
    def initialize
      subdomain = ENV['PWINTY_PRODUCTION'] == 'true' ? "api" : "sandbox"
      domain = "https://#{subdomain}.pwinty.com/v2.1"

      @pwinty = RestClient::Resource.new(domain, :headers => {
        "X-Pwinty-MerchantId" => ENV['PWINTY_MERCHANT_ID'],
        "X-Pwinty-REST-API-Key" => ENV['PWINTY_API_KEY'],
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

    # post :add_photos, "/Orders/:orderId/Photos/Batch"
    def delete_photo(orderId, photoId)
      JSON.parse @pwinty["/Orders/#{orderId}/Photos/#{photoId}"].delete
    end

    # Countries
    def countries
      JSON.parse @pwinty["/Country"].get
    end
  end
end
