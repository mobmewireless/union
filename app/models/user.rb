class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :omniauthable, omniauth_providers: [:google_oauth2]

  validate :validate_host

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.skip_confirmation!
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.email = auth.info.email
    end
  end

  private

  def validate_host
    if email
      if APP_CONFIG[:allowed_email_host]
        unless email.ends_with? "@#{APP_CONFIG[:allowed_email_host]}"
          errors.add(:base, 'You are not allowed to use this service.')
        end
      end
    end
  end
end
