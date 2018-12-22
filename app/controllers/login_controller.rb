class LoginController < ApplicationController
  require 'rest-client'

  def login
    unless params[:request_type].nil?
      respond_to do |format|
        login_handler
        format.html
        format.js
      end
    end
  end

  def login_handler
    @message = ''
    @user = User.find_by_email(params[:email]) # does the user exists
    case params[:request_type]
    when 'login'
      login_user
    when 'confirm_user'
      confirm_user
    when 'create_user'
      create_user
    else
      raise StandardError
    end
  end

  def create_user
    # create the user in the server and the client server
    begin
      response=RestClient.post('localhost:8086/playground/users',
                               {
                                   "email": params[:email],
                                   "username": params[:user_name],
                                   "avatar": params[:avatar],
                                   "role": params[:role]
                               }.to_json,content_type: :json, accept: :json)
      userTo = JSON.parse(response.body)

      @user = User.create(email:userTo['email'],
                          playground: userTo['playground'],
                          username: userTo['username'],
                          avatar: userTo['avatar'], verified: 0,
                          points: 10000, role: userTo['role'])
      @message = 'User Created'
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured #{JSON.parse(e.response)['message']}"
    rescue StandardError => e
      @message = "Error occured #{e.message}"
    end
  end


  def confirm_user
    # confirm the user and update the databases
    begin
      # get the user from the java server
      RestClient.get("localhost:8086/playground/users/confirm/#{@user.playground}/#{params[:email]}/#{params[:code_validation].to_s}")
      @user.verify
      @message = 'User Validated'
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured #{JSON.parse(e.response)['message']}"
    end
  rescue StandardError => e
    @message =  "Error occured #{e.message}"
  end

  def login_user
    # login the user to the server
    if validate_user_on_server
      begin
        response = RestClient.get("localhost:8086/playground/users/login/#{params[:playground]}/#{params[:email]}")
        if response.code == 200
          session[:user] = params[:email]
          session[:playground] = params[:playground]
          @user.role == 'Manager'? (redirect_to('/api_admin')):(redirect_to('/api_user'))
        end
      rescue RestClient::ExceptionWithResponse => e
        @message = "Error occured #{JSON.parse(e.response)['message']}"
      rescue StandardError => e
        @message =  "Error occured #{e.message}"
      end
    end
  end

  def validate_user_on_server
    # make sure that the local db matches the data on the server db
    begin
      response = RestClient.get("localhost:8086/playground/users/login/#{params[:playground]}/#{params[:email]}")
      server_user = JSON.parse(response.body)
      # update the local db
      if @user.nil? # add user to client db if data is missing on the client
        @user = User.create(email:server_user['email'],
                            playground: server_user['playground'],
                            username: server_user['username'],
                            avatar: server_user['avatar'], verified: 1,
                            points: server_user['points'], role: server_user['role'])
      else
        @user.update(server_user['avatar'], server_user['role'], server_user['username'], server_user['points'])
      end
    rescue StandardError => e
      @message =  "Error occured #{e.message}"
      false
    end
  end
end
