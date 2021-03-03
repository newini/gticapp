class SessionsController < ApplicationController

#  def new
#  end

  def create
    # request staff info. from facebook
    auth = request.env["omniauth.auth"]
    # find staff by facebook id
    staff = Staff.find_by_uid(auth["uid"])

    # Check if loged
    if !staff
      # Show staff id
      logger.info("[sesstions_info] Unknown gtic staff name: " + auth['info']['name'] + ", uid: " + auth["uid"])
      redirect_to root_url, :notice => "Cannot login! Please contact to admin! ID: " + auth["uid"]
    else
      logger.info("[sesstions_info] Gtic staff name: " + auth['info']['name'] + ", uid: " + auth["uid"])
      # Update facebook info when sign in
      staff.update(provider:     auth["provider"],
                  name:         auth["info"]["name"],
                  uid:          auth["uid"],
                  email:        auth["info"]["email"],
                  image_url:    auth["info"]["image"],
                  access_token: auth["credentials"]["token"])

      session[:staff_id] = staff.id

      # Expire time
      session[:expires_at] = Time.current + 24.hours

      if !staff.active_flg
        redirect_to root_url, :notice => "Cannot login! You don't have access authority! Please contact to admin!"
      end

      # Update gtic flag
      member = Member.find_by_id(staff.member_id)
      if member
          member.update(gtic_flg: true)
          redirect_to root_url, :notice => "Welcome! [sys] Updated gtic flag."
      else
          redirect_to root_url, :notice => "Welcome! [sys] Cannot update gtic flg!"
      end
    end
  end

  def destroy
    session[:staff_id] = nil
    sign_out
    redirect_to root_url, :notice => "サインアウトしました"
  end

end
