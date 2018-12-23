class ApiAdminController < ApplicationController
  require 'rest-client'
  require 'json'
  include Element
  include Activity

  def api_admin
    @message = ''
    @user = User.find_by_email(session[:user])
    #redirect_to '/api_user' if @user.role == 'Player' # activate after I create the same edit user in player section
    @elements = get_all_elements
    @element_edit = {}
    @attr_elements = []
    @location_elements = []
    unless params[:request_type].blank?
      case params[:request_type]
      when 'edit_user'
        edit_user
      when 'element_action'
        element_actions
      when 'activity_action'

      end
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def element_actions
    #Get,Edit and Create element
    case params[:commit]
    when 'Get Element Data'
      get_element
    when 'Edit Element'
      edit_element
    when 'Create Element'
      create_element
    when 'Get All Element By Attribute'
      get_elements_by_attribute
    when 'Get Elements By Location'
      get_elements_by_location
    end
  end

  def activity_actions

  end

  def edit_user
    begin
      response = RestClient.put("localhost:8086/playground/users/#{@user.playground}/#{@user.email}",{
          "email": @user.email,
          "playground": @user.playground,
          "username": params[:user_name],
          "avatar": params[:avatar],
          "role": params[:role],
          "points": @user.points
      }.to_json,content_type: :json, accept: :json)
      if response.code == 200
        # update user on client
        @user.update(params[:avatar], params[:role], params[:user_name], @user.points)
        @message = 'User updated'
      end

    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured #{JSON.parse(e.response)['message']}"
    rescue StandardError => e
      @message =  "Error occured #{e.message}"
    end
  end


end
