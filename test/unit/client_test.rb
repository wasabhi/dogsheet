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
end
