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
        "X-Pwinty-REST-API-Key" => ENV['PWINTY_API_KEY']
      })
    end

    def catalog(countryCode, qualityLevel)
      @pwinty["/Catalogue/#{countryCode}/#{qualityLevel}"].get
    end

    # Orders
    def get_orders
      @pwinty["/Orders"].get
    end

    def create_order(recipientName, address1, addressTownOrCity,
                     stateOrCounty, postalOrZipCode, countryCode,
                     payment, qualityLevel, address2 = nil,
                     useTrackedShipping = nil, destinationCountryCode = nil
                    )
      args = {
        recipientName: recipientName,
        address1: address1,
        addressTownOrCity: addressTownOrCity, 
        stateOrCounty: stateOrCounty,
        postalOrZipCode: postalOrZipCode,
        countryCode: countryCode,
        payment: payment,
        qualityLevel: qualityLevel
      }

      args[:useTrackedShipping]     = useTrackedShipping     if useTrackedShipping.present?
      args[:destinationCountryCode] = destinationCountryCode if destinationCountryCode.present?
      args[:address2]               = address2               if address2.present?

      @pwinty["/Orders"].post args
    end

    # def update_order(id, recipientName, address1, addressTownOrCity,
    #                  stateOrCounty, postalOrZipCode, countryCode,
    #                  payment, qualityLevel,
    #                 payment, qualityLevel, address2 = nil,
    #                 useTrackedShipping = nil, destinationCountryCode = nil
    #   args = {
    #     recipientName: recipientName,
    #     address1: address1,
    #     addressTownOrCity: addressTownOrCity, 
    #     stateOrCounty: stateOrCounty,
    #     postalOrZipCode: postalOrZipCode,
    #     countryCode: countryCode,
    #     payment: payment,
    #     qualityLevel: qualityLevel
    #   }

    #   args[:useTrackedShipping]     = useTrackedShipping     if useTrackedShipping.present?
    #   args[:destinationCountryCode] = destinationCountryCode if destinationCountryCode.present?
    #   args[:address2]               = address2               if address2.present?

    #   @pwinty["/Orders/#{id}"].put args
    # end

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


    def add_photo(orderId, type, copies, sizing, file = nil, url = nil)
      args = {
        type: type,
        copies: copies,
        sizing: sizing
      }
      args[:file] = file if file.present?
      args[:url]  = url  if url.present?

      headers = {}
      headers["Content-Type"] = "multipart/form-data" if file.present?

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
