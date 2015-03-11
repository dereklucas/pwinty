require "pwinty/version"
require "weary"
require "active_attr"

module Pwinty

  def self.client
    @@client ||= Pwinty::Client.new
    @@client
  end

  class Order
  end

  class Photo
  end

  class Client < Weary::Client
    domain "https://sandbox.pwinty.com/v2.1"

    headers "X-Pwinty-MerchantId" => ENV['PWINTY_MERCHANT_ID'],
    			  "X-Pwinty-REST-API-Key" => ENV['PWINTY_API_KEY']

    get :catalog, "/Catalogue/:countryCode/:qualityLevel"

    # Orders
    get  :get_orders,   "/Orders"
    post :create_order, "/Orders" do |resource|
      resource.required :recipientName, :address1, :addressTownOrCity, 
                        :stateOrCounty, :postalOrZipCode, :countryCode,
                        :payment, :qualityLevel
      resource.optional :useTrackedShipping, :destinationCountryCode, :address1
      resource.headers {'Content-Type' => 'multipart/form-data'}
    end
    put :update_order, "/Orders/:id"

    # Order Status
    get  :get_order_status, "/Orders/:id/SubmissionStatus"
    post :set_order_status, "/Orders/:id/Status" do |resource|
      resource.required :status
    end

    # Order Photos
    get  :get_photos, "/Orders/:orderId/Photos"
    get  :get_photo,  "/Orders/:orderId/Photos/:photoId"
    post :add_photo,  "/Orders/:orderId/Photos" do |resource|
      resource.required :type, :copies, :sizing
      resource.optional :file, :url
    end
    post :add_photos, "/Orders/:orderId/Photos/Batch"
    delete :delete_photo, "/Orders/:orderId/Photos/:photoId"

    # Countries
    get :countries, "/Country"
  end
end
