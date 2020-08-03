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
      logger.info("[sesstions_info] Unknown gtic user name: " + auth['info']['name'] + ", uid: " + auth["uid"])
      redirect_to root_url, :notice => "Cannot login! Please contact to admin! ID: " + auth["uid"]
    else
      logger.info("[sesstions_info] Gtic user name: " + auth['info']['name'] + ", uid: " + auth["uid"])
      # Update facebook info when sign in
      user.update(provider:     auth["provider"],
                  name:         auth["info"]["name"],
                  uid:          auth["uid"],
                  email:        auth["info"]["email"],
                  image_url:    auth["info"]["image"],
                  access_token: auth["credentials"]["token"])

      session[:user_id] = user.id

      # Expire time
      session[:expires_at] = Time.current + 24.hours

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
  end

  def destroy
    session[:user_id] = nil
    sign_out
    redirect_to root_url, :notice => "サインアウトしました"
  end

end
