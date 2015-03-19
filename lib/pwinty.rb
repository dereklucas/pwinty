require "pwinty/version"
require 'rest_client'

BOUNDARY = "AaB03x"

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
      @pwinty["/Orders/#{args[:id]}"].put args
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
      orderId = args.delete(:orderId)

      unless args[:asset].nil?
        headers = {"Content-Type" => "multipart/form-data, boundary=#{BOUNDARY}"}
        args = build_upload(args)
      end

      @pwinty["/Orders/#{orderId}/Photos"].post args
    end

    # post :add_photos, "/Orders/:orderId/Photos/Batch"
    def delete_photo(orderId, photoId)
      @pwinty["/Orders/#{orderId}/Photos/#{photoId}"].delete
    end

    # Countries
    def countries
      @pwinty["/Country"].get
    end

    private

    def build_upload(args)
      # We're going to compile all the parts of the body into an array, then join them into one single string
      # This method reads the given file into memory all at once, thus it might not work well for large files
      post_body = []

      asset = args.delete(:asset)
      args.each do |key, value|
        post_body << "--#{BOUNDARY}\r\n"
        post_body << "Content-Disposition: form-data; name=\"key\"\r\n\r\n"
        post_body << value
      end

      # Add the file Data
      post_body << "--#{BOUNDARY}\r\n"
      post_body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{asset.original_filename}\"\r\n"
      post_body << "Content-Type: #{MIME::Types.type_for(asset.original_filename)}\r\n\r\n"
      post_body << asset.file_for(:pristine).read

      post_body << "\r\n\r\n--#{BOUNDARY}--\r\n"

      return post_body.join
    end
  end
end
