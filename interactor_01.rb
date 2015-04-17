class SessionsController
  def create
    unless params[:email].present?
      Rails.logger.error("Login failed because missing email")
      respond_with_failure
    end

    user = User.find_by_email(params[:email])

    unless user.present?
      Rails.logger.error("Login failed because email not found")
      respond_with_failure
    end

    authenticator = UserAuthenticationService.new(user, password)

    unless authenticator.matches?
      Rails.logger.error("Login failed because incorrect password")
      respond_with_failure
    end

    unless user.active?
      Rails.logger.error("Login failed because account is disabled")
      respond_with_failure "Account Disabled. Please contact customer service for more information."
    end

    Rails.logger.info("Successful login with email/password")

    sign_in(user)
    set_user_analytics_cookie
    track_seller_campaign_status

    respond_with_user
  end
end
