Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook,
    Settings.OmniAuth.facebook.app_id,
    Settings.OmniAuth.facebook.app_secret,
end
