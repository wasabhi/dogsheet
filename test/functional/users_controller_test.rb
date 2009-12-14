require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def test_should_get_new
    get :new
    assert_not_nil assigns(:user)
    assert_response :success
  end

  def test_should_create_user
    assert_difference('User.count') do
      post :create, :user => { 
        :name => 'Test User', :email => 'test@example.com',
        :password => 'password', :password_confirmation => 'password'
      }
    end
  end
 
  def test_should_not_edit_user_when_not_logged_in
    get :edit
    assert_redirected_to new_user_session_url
  end

  def test_should_edit_user
    UserSession.create(users(:one))
    get :edit
    assert_response :success
    assert_not_nil assigns(:user)
  end

  def test_should_not_create_user_when_logged_in
    UserSession.create(users(:one))
    post :create, :user => { 
      :name => 'Test User', :email => 'test@example.com',
      :password => 'password', :password_confirmation => 'password'
    }
    assert_redirected_to root_url
  end
end
