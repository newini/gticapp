Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
    Settings.OmniAuth.facebook.app_id,
    Settings.OmniAuth.facebook.app_secret,
    :scope => 'offline_access,email,user_birthday,read_stream,create_event,user_events'
end
