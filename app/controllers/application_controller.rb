class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user_session, :current_user

  private
    def current_user_session
      logger.debug "ApplicationController::current_user_session"
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      logger.debug "ApplicationController::current_user"
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end

    def require_user
      logger.debug "ApplicationController::require_user"
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url

        return false
      end
    end

    def require_no_user

      logger.debug "ApplicationController::require_no_user"

      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_to admin_users_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    #TODO下はアクセス制限チェック用だが、訂正必要かも
    # 管理者アクセスチェック
    def check_admin
      if current_user.roles.admin
        return true
      elsif current_user.roles.sender
        redirect_to sender_users_url
      elsif current_user.roles.receiver
        redirect_to receiver_massages_url
      end
    end

    #senderチェック
    def check_sender
      if current_user.roles.sender
        return true
      elsif current_user.roles.admin
        redirect_to admin_users_url
      elsif current_user.roles.receiver
        redirect_to receiver_massages_url
      end
    end

    #receiverチェック
    def check_receiver
      if current_user.roles.receiver
        return true
      elsif current_user.roles.admin
        redirect_to admin_users_url
      elsif current_user.roles.sender
        redirect_to sender_users_url
      end
    end
end
