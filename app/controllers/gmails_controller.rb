class GmailsController < ApplicationController
  include GmailsHelper
  before_action :signed_in_user

  def redirect
    client = Signet::OAuth2::Client.new({
      client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
      client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      scope: Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
      redirect_uri: url_for(:action => :callback)
    })

    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new({
      client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
      client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET')
    })
    client.token_credential_uri = 'https://www.googleapis.com/oauth2/v3/token'
    client.redirect_uri = url_for(action: :callback)
    client.code = params[:code]
    response = client.fetch_access_token!
    session[:access_token] = response['access_token']
    redirect_to url_for(action: :getmail)
  end

  def getmail
    token = session[:access_token]
    query = ""
    #@messages = get_messages(token, query)["messages"]

    client = Signet::OAuth2::Client.new(access_token: session[:access_token])
    service = Google::Apis::GmailV1::GmailService.new
    service.authorization = client
    @labels_list = service.list_user_labels('me')
  end

end
