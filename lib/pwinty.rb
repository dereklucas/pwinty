require "pwinty/version"
require 'rest_client'

module Pwinty

  def self.client
    @@client ||= Pwinty::Client.new
    @@client
  end

  class Client
    def initialize
      domain = "https://sandbox.pwinty.com/v2.1" #: "https://sandbox.pwinty.com/v2.1"
      @pwinty = RestClient::Resource.new(domain, :headers => {
        "X-Pwinty-MerchantId" => ENV['PWINTY_MERCHANT_ID'],
        "X-Pwinty-REST-API-Key" => ENV['PWINTY_API_KEY'],
        'Accept' => 'application/json'
      })
    end

    def catalog(countryCode: 'US', qualityLevel: 'Standard')
      @pwinty["/Catalogue/#{countryCode}/#{qualityLevel}"].get
    end

    # Orders
    def get_orders
      @pwinty["/Orders"].get
    end

    def create_order(**args)
      @pwinty["/Orders"].post args
    end

    def update_order(**args)
      @pwinty["/Orders/#{id}"].put args
    end

    # Order Status
    def get_order_status(id)
      @pwinty["/Orders/#{id}/SubmissionStatus"].get
    end

    def update_order_status(id, status)
      @pwinty["/Orders/#{id}/Status"].post status: status
    end

    # Order Photos
    def get_photos(orderId)
      @pwinty["/Orders/#{orderId}/Photos"].get
    end

    def get_photo(orderId, photoId)
      @pwinty["/Orders/#{orderId}/Photos/#{photoId}"].get
    end


    def add_photo(**args)
      headers = {}
      headers["Content-Type"] = "multipart/form-data" if args[:file].present?

      @pwinty["/Orders/#{orderId}/Photos"].post args, headers
    end

    # post :add_photos, "/Orders/:orderId/Photos/Batch"
    def delete_photo(orderId, photoId)
      @pwinty["/Orders/#{orderId}/Photos/#{photoId}"].delete
    end

    # Countries
    def countries
      @pwinty["/Country"].get
    end
  end
end
