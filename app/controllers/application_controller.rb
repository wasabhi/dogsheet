# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :current_user

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b39307728a527492d5247eabdcebd999'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  before_filter :require_login
  before_filter :set_time_zone

  # By default throw 404 for all record not found
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  # Before filter to check for user login in any controller
  def require_login
    unless current_user
      flash[:notice] = 'You must be logged in to view this page'
      redirect_to new_user_session_url
      return false
    end
  end

  def set_time_zone
    Time.zone = current_user.time_zone if current_user
  end

  protected
  def render_404
    respond_to do |format|
      format.html do
        render :file => "#{RAILS_ROOT}/public/404.html", 
                :status => '404 Not Found'
      end
      format.xml do
        render :nothing => true, :status => '404 Not Found'
      end
    end
  end

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
  end
end
