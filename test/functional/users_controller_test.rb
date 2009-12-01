require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_should_get_new
    get :new
    assert_not_nil assigns(:user)
    assert_response :success
  end

  def test_should_create_user
    flunk
 
  def test_should_not_edit_user_when_not_logged_in
    flunk
  end

  def test_should_edit_user
    flunk
  end

  def test_should_not_edit_another_user
    flunk
  end
 end
end
