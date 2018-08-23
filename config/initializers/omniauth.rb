Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
    Settings.OmniAuth.facebook.app_id,
    Settings.OmniAuth.facebook.app_secret,
    #:scope => 'email,user_birthday,user_events'
    :scope => 'email,user_birthday'
end
