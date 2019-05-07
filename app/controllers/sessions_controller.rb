class SessionsController < ApplicationController

#  def new
#  end

  def create
    # request user info. from facebook
    auth = request.env["omniauth.auth"]
    # find user by facebook id
    user = User.find_by_uid(auth["uid"])

    # Check if loged
    if !user
      # Show user id
      redirect_to root_url, :notice => "Cannot login! Please contact to admin! ID: " + auth["uid"]
    else
      # Update facebook info when sign in 
      user.update(provider: auth["provider"],
                  name:      auth["info"]["name"],
                  uid:     auth["uid"],
                  email:     auth["info"]["email"],
                  image_url: auth["info"]["image"],
                  access_token: auth["credentials"]["token"])

      session[:user_id] = user.id

      if !user.active_flg
        redirect_to root_url, :notice => "Cannot login! You don't have access authority! Please contact to admin!"
      end

      # Update gtic flag
      member = Member.find_by_id(user.member_id)
      if member
          member.update(gtic_flg: true)
          redirect_to root_url, :notice => "Welcome! [sys] Updated gtic flag."
      else
          redirect_to root_url, :notice => "Welcome! [sys] Cannot update gtic flg!"
      end
    end

#    if !user
#      user = User.find_by_email(auth["info"]["email"])
#    end

    # comment out below when not use
#    if !user 
#      user = User.create_with_omniauth(auth)
#    end

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
    sign_out
    redirect_to root_url, :notice => "サインアウトしました"
  end

end
