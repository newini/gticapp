class SessionsController < ApplicationController
#  def new
#  end
  def create
#    raise request.env["omniauth.auth"].to_yaml  
    auth = request.env["omniauth.auth"]
    user = User.find_by_uid(auth["uid"])
    if user.provider.nil?
      user = user.update(provider: auth["provider"],
                         name:      auth["info"]["name"],
                         email:     auth["info"]["email"],
                         image_url: auth["info"]["image"],
                         access_token: auth["credentials"]["token"])
      user.save
    end

    #user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    redirect_to root_url, :notice => "サインインしました"
#    if user && user.authenticate(params[:session][:password])
#    user = User.find_by(email: params[:session][:email].downcase)
#    if user && user.authenticate(params[:session][:password])
#      sign_in user
#      redirect_to members_path 
#    else
#      flash.now[:error] = 'Invalid email/password combination'
#      render 'new'
#    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "サインアウトしました"
#    sign_out
#    redirect_to root_path
  end
end
