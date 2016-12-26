require "test_helper"

class TestClient < Test::Unit::TestCase

  def setup
    @params = {
      recipientName: "FirstName LastName",
      address1: "123 Anywhere Street",
      addressTownOrCity: "San Francisco",
      stateOrCounty: "CA",
      postalOrZipCode: "94101",
      countryCode: "US",
      payment: "InvoiceMe",
      qualityLevel: "Standard"
    }

    @client = Pwinty.client(merchant_id: ENV['PWINTY_MERCHANT_ID'], api_key: ENV['PWINTY_API_KEY'], production: false)

    @order_keys = %w[ id status price
                      address1 address2
                      addressTownOrCity
                      countryCode
                      destinationCountryCode
                      errorMessage qualityLevel
                      payment paymentUrl
                      photos postalOrZipCode
                      recipientName shippingInfo
                      stateOrCounty ]
  end

  def test_initialize
    body = @client.catalog
    assert_equal body.class, Hash
  end

  def test_catalog_integration
    body = @client.catalog
    assert_equal body.class, Hash
    assert_equal body["countryCode"], "US"
    assert_equal body["qualityLevel"], "Standard"
    assert_equal body["shippingRates"].class, Array
    assert_equal body["items"].class, Array
  end
  def test_get_orders_integration
    # NOTE: works only if you already have an order created. the first ever test run will probably fail
    body = @client.get_orders
    assert_equal body.class, Array
    assert_equal body.first.keys.sort!, @order_keys.sort!
  end
  def test_countries_integration
    body = @client.countries
    keys = %w[ countryCode name
               hasProducts errorMessage ]

    assert_equal body.class, Array
    assert_equal body.first.keys.sort!, keys.sort!
  end

  def test_orders_integration
    # create Order
    body = @client.create_order(@params)
    assert_equal body.keys.sort!, @order_keys.sort!
    assert_equal body["postalOrZipCode"], "94101"
    id = body["id"]


    body = @client.update_order(id: id, recipientName: 'Travis CI', postalOrZipCode: '94102')
    assert_equal body.keys.sort!, @order_keys.sort!
    assert_equal body["postalOrZipCode"], "94102"

    # add Photo to Order via URL
    body = @client.add_photo(orderId: id,
                             type: "4x6",
                             url: "http://i.imgur.com/xXnrL.jpg",
                             copies: 1, sizing: "Crop")
    photo_id = body['id']
    first_photo = body

    keys = %w[ id type url
               status copies
               sizing priceToUser
               price md5Hash previewUrl
               thumbnailUrl attributes
               errorMessage ]

    assert_equal body.keys.sort!, keys.sort!

    # Check photo was uploaded
    body = @client.get_photos(id)
    assert_equal body.length, 1
    assert_equal body.first, first_photo

    # Check photo was uploaded
    body = @client.get_photo(id, photo_id)
    assert_equal body, first_photo

    # Delete photo
    body = @client.delete_photo(id, photo_id)
    assert_equal body['errorMessage'], nil

    # TODO: Need to add a photo via file

    # get Order Status
    body = @client.get_order_status(id)
    keys = %w[id isValid generalErrors photos]
    if body["error"]
      assert body["error"].class, String
    else
      assert_equal body.keys.sort!, keys.sort!
    end

    # Cancel Order
    body = @client.update_order_status(id, "Cancelled")
    assert_equal body['errorMessage'], nil
  end

end
