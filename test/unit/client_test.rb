require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  def test_should_not_save_client_without_email
    client = Client.new
    client.name = "Test client"
    assert !client.save, "Saved the client without an email address"
  end

  def test_should_not_save_client_without_name
    client = Client.new
    client.email = "test@example.com"
    assert !client.save, "Saved the client without a name"
  end

  def test_should_not_save_client_with_invlaid_email
    client = Client.new
    client.name = "Test client"
    client.email = "invalid@com"
    assert !client.save, "Saved the client with an invalid email address"
  end

  def test_should_save_client
    client = Client.new
    client.name = "Test client"
    client.email = "valid@example.com"
    assert client.save, "Saved a valid client"
  end

  def test_should_return_short_code
    client = Client.new

    client.name = "Test Client"
    assert_equal 'TC', client.shortcode, "return initials"

    client.name = "Test Client With more Than four words"
    assert_equal 'TCWM', client.shortcode, "returns only first 4 initials"

    client.name = "TestClientWithOneWord"
    assert_equal 'TEST', client.shortcode, "returns first 4 chars of one word client name"
  end
end
