class XeroSessionsController < ApplicationController

  before_filter :get_xero_gateway

  def new
    session[:request_token]  = @xero_gateway.request_token.token
    session[:request_secret] = @xero_gateway.request_token.secret

    redirect_to @xero_gateway.request_token.authorize_url
  end

  def create
    @xero_gateway.authorize_from_request(session[:request_token], session[:request_secret],
                                         :oauth_verifier => params[:oauth_verifier])

    session[:xero_auth] = { :access_token  => @xero_gateway.access_token.token, 
                            :access_secret => @xero_gateway.access_token.secret }

    session.data.delete(:request_token); session.data.delete(:request_secret)
    redirect_to session.data.delete(:xero_redirect_to) || root_url
  end

  def destroy
    session[:xero_auth] = nil
    redirect_to root_url
  end

end

