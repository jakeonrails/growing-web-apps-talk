module Core
  class AuthenticateUserFromEmailAndPassword

    attr_writer :user_repository, :user_authenticator

    EmailNotFound = Class.new(StandardError)
    UserDisabled  = Class.new(StandardError)
    PasswordDoesNotMatch = Class.new(StandardError)
    MissingEmail = Class.new(StandardError)

    def initialize(params)
      @email    = params.fetch(:email)
      @password = params.fetch(:password)
    end

    def execute
      if email.blank?
        Rails.logger.error("Login failed because email not found")
        fail MissingEmail
      end
      if user.nil?
        Rails.logger.error("Login failed because account is disabled")
        fail EmailNotFound
      end
      unless user_authenticator.matches?
        Rails.logger.error("Login failed because of an incorrect password")
        fail PasswordDoesNotMatch
      end
      unless user.is_active?
        Rails.logger.error("Login failed because user is inactive")
        fail UserDisabled
      end
      Rails.logger.info("Successful login with email/password")
      user
    end

    private

    attr_reader :email, :password

    def user
      @user ||= user_repository.find_by_email(email)
    end

    def user_repository
      @user_repository ||= User
    end

    def user_authenticator
      @user_authenticator ||= UserAuthenticationService.new(user, password)
    end

  end
end
