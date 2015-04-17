def SessionsController
  def create
    user = AuthenticateUserFromEmailAndPassword.new(params).execute
    sign_in(user)
    set_user_analytics_cookie
    track_seller_campaign_status

    respond_with_user

  rescue AuthenticateUserFromEmailAndPassword::UserDisabled,
         AuthenticateUserFromEmailAndPassword::EmailNotFound,
         AuthenticateUserFromEmailAndPassword::PasswordDoesNotMatch,
         AuthenticateUserFromEmailAndPassword::MissingEmail

    respond_with_failure
  end
end


class Interactor
  def self.[](params)
    new(params).execute
  end
end

Authenticate[password, email]
