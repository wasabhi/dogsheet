require 'test_helper'

class ClientsControllerTest < ActionController::TestCase

  setup :activate_authlogic

  def test_should_redirect_index_if_logged_out
    get :index
    assert_redirected_to new_user_session_url
  end

  def test_should_get_index
    UserSession.create(users(:one))
    get :index
    assert_response :success
    assert_not_nil assigns(:clients)
  end

  def test_should_redirect_new_if_logged_out
    get :new
    assert_redirected_to new_user_session_url
  end

  def test_should_get_new
    UserSession.create(users(:one))
    get :new
    assert_response :success
  end

  def test_should_redirect_create_if_logged_out
    post :create, :client => { :name => 'Malc', :email => 'malc@example.com' }
    assert_redirected_to new_user_session_url
  end

  def test_should_create_client
    UserSession.create(users(:one))
    assert_difference('Client.count') do
      post :create, :client => { :name => 'Malc', :email => 'malc@example.com' }
    end

    assert_redirected_to client_path(assigns(:client))
  end

  def test_should_redirect_show_if_logged_out
    get :show, :id => clients(:one).id
    assert_redirected_to new_user_session_url
  end

  def test_should_show_client
    UserSession.create(users(:one))
    get :show, :id => clients(:one).id
    assert_response :success
  end

  def test_should_redirect_edit_if_logged_out
    get :edit, :id => clients(:one).id
    assert_redirected_to new_user_session_url
  end

  def test_should_get_edit
    UserSession.create(users(:one))
    get :edit, :id => clients(:one).id
    assert_response :success
  end

  def test_should_redirect_update_if_logged_out
    put :update, :id => clients(:one).id, :client => { :name => 'Malc', :email => 'malc@example.com' }
    assert_redirected_to new_user_session_url
  end

  def test_should_update_client
    UserSession.create(users(:one))
    put :update, :id => clients(:one).id, :client => { :name => 'Malc', :email => 'malc@example.com' }
    assert_redirected_to client_path(assigns(:client))
  end

  def test_should_redirect_destroy_if_logged_out
    delete :destroy, :id => clients(:one).id
    assert_redirected_to new_user_session_url
  end
    
  def test_should_destroy_client
    UserSession.create(users(:one))
    assert_difference('Client.count', -1) do
      delete :destroy, :id => clients(:one).id
    end

    assert_redirected_to clients_path
  end
end
