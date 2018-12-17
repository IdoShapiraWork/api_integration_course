class LoginController < ApplicationController
  require 'rest-client'

  def login
    unless params[:request_type].nil?
      respond_to do |format|
        @message = login_handler
        format.html
        format.js
      end
    end
  end

  def login_handler
    message = ''
    case params[:request_type]
    when 'login'
      @user = User.find_by_email_playground("#{params[:playground]}&#{params[:email]}") # does the user exists
      if !@user.nil?
        if @user.verified == 1 # is the user verified
          puts 'logged in'
        else
          puts 'not verified'
        end
      else
        puts 'email does not exist with the attached playground'
      end
    when 'confirm_user'
      2
    when 'create_user'
      # create the user locally
      message=create_user
      3
    else
      raise StandardError
    end
    message
  end

  def create_user
    # create the user
    begin
      response=RestClient.post('localhost:8086/playground/users',
                               {
                                   "email": params[:email],
                                   "playground": params[:playground],
                                   "username": params[:user_name],
                                   "avatar": params[:avatar],
                                   "role": params[:role]
                               }.to_json,{content_type: :json, accept: :json})
      @user = User.create(email:params[:email],playground:params[:playground], username: params[:user_name],
                          avatar: params[:avatar], verified: 0, points: 10000, role: params[:role])
      return 'User Created'
    rescue RestClient::ExceptionWithResponse => e
      return "Error occured #{JSON.parse(e.response)['message']}"
    end
  end
end
