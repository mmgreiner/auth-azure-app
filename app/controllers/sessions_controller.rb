class SessionsController < ApplicationController
  def new
  end

  def create
    logger.info "create with #{params}"
    auth = request.env["omniauth.auth"]
    # could add guard if auth is nil

    user = User.find_or_create_by!(provider: auth["provider"], uid: auth["uid"]) do |u|
      u.first_name = auth["info"]["first_name"]
      u.last_name = auth["info"]["last_name"]
      u.email = auth["info"]["email"]
    end

    session[:user_id] = user.id
    redirect_to root_path, notice: "Signed in #{user.email} successfully"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully"
  end
end
