class Identity < OmniAuth::Identity::Models::ActiveRecord
  attr_accessible :name, :email, :password, :password_confirmation

  validates_uniqueness_of :email
  validates_presence_of :name
  validate :email_host

  private
  def email_host
    if email
      unless email.ends_with? "@#{APP_CONFIG[:allowed_email_host]}"
        errors.add(:base, 'Must use an allowed email host.')
      end
    end
  end
end
