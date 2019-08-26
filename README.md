# DEPRECATED: Migrate to [API v3](https://github.com/tomharvey/pwinty3-rb)


# Pwinty v2 [![Build Status](https://secure.travis-ci.org/dereklucas/pwinty.png)](http://travis-ci.org/dereklucas/pwinty?branch=master)

This library implements a Ruby client for the [Pwinty photo printing API](http://www.pwinty.com/Api).

While I consider this to be feature complete (it's the only Ruby Pwinty client that can `POST` photos as well as send photo URLs), I do want to hear if there are issues.

Documentation
-------------

Import pwinty and set your API Key and Merchent ID:

    ENV['PWINTY_MERCHANT_ID'] = 'xxxxxxx'
    ENV['PWINTY_API_KEY'] = 'xxxxxxx'
    @client = Pwinty.client

Create an Order:

    order = @client.Order.create_order(
      recipientName: "FirstName LastName",
      address1: "123 Anywhere Street",
      addressTownOrCity: "San Francisco",
      stateOrCounty: "CA",
      postalOrZipCode: "94101",
      countryCode: "US",
      payment: "InvoiceMe",
      qualityLevel: "Standard"
    )

Add photos to the order:

    photo = @client.add_photo(
      orderId: order['id'],
      type: "4x6",
      url: "http://i.imgur.com/xXnrL.jpg",
      copies: 1,
      sizing: "Crop"
    )

Check the order is valid:

  	order_status = @client.get_order_status(order['id'])
  	if !order_status['isValid']
  		puts "Invalid Order"
    end

Submit the order:

    response = @client.update_order_status(order['id'], "Submitted")


You can retrieve a previous order and check its status like so:

    order = @client.get_order_status(8765)
    if order['status'] == 'Complete'
    	puts "Order has dispatched"
    end

You should find the documentation for Pwinty on [their API](https://pwinty.com/Api).

Install
--------

```shell
gem install pwinty
```
or add the following line to Gemfile:

```ruby
gem 'pwinty'
```
and run `bundle install` from your shell.

Supported Ruby versions
-----------------------

The Ruby Pwinty gem has only been tested on Ruby 2.

License
-------

MIT License

More Information
----------------

* [Rubygems](https://rubygems.org/gems/pwinty)
* [Issues](https://github.com/dereklucas/pwinty/issues)
* Follows [SemVer](http://semver.org)
