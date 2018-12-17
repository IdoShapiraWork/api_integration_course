class ApiAdminController < ApplicationController
  def api_admin
    @user = User.find_by_email(session[:email])
  end
end
