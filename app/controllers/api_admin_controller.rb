class ApiAdminController < ApplicationController
  require 'rest-client'
  require 'json'
  def api_admin
    @message = ''
    @user = User.find_by_email(session[:user])
    #redirect_to '/api_user' if @user.role == 'Player' # activate after I create the same edit user in player section
    @elements = get_all_elements
    @element_edit = {}
    unless params[:request_type].blank?
      case params[:request_type]
      when 'edit_user'
        edit_user
      when 'element_action'
        element_actions
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
    when 'Create Element'
      create_element
    end

  end

  def get_element
    begin
      response = RestClient.get("localhost:8086/elementEntities/#{@user.playground}&#{params[:element_id]}")
      @element_edit = JSON.parse(response.body)
      @element_edit['attributes_print'] = ''
       @element_edit['attributes'].each do |h,v|
         @element_edit['attributes_print'] << "#{h}:#{v}"
      end
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured: Element not found"
    rescue StandardError => e
      @message =  "Error occured #{e}"
    end
  end

  def get_all_elements
    checker = true
    page = 0
    json_array = []
    while checker
      response=RestClient.get("http://localhost:8086/playground/elements/#{@user.playground}/#{@user.email}/all?size=5&page=#{page}")
      objArray = JSON.parse(response.body)

      if objArray.length == 0
        checker = false
      else
        objArray.each do |json|
          json_array << json
        end

        page += 1
      end
    end
    json_array.to_json
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
      puts response.code
      if response.code == 200
        # update user on client
        @user.update(params[:avatar], params[:role], params[:user_name], params[:points])
      end
      puts 'isdf'
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured #{JSON.parse(e.response)['message']}"
    rescue StandardError => e
      @message =  "Error occured #{e.message}"
    end
  end

  def create_element
    @user = User.find_by_email(session[:user])
    attributes = {}
    location = {}
    attributes_data = params[:attributes].split(',')
    attributes_data.each do |data|
      attr=data.split(':')
      attributes[attr[0]] = attr[1]
    end
    location['x'] = params[:location_x] unless params[:location_x].blank?
    location['y'] = params[:location_y] unless params[:location_y].blank?

    begin
      response=RestClient.post("localhost:8086/playground/elements/#{@user.playground}/#{@user.email}",
                               {
                                   "location": location,
                                   "attributes": attributes,
                                   "name": params[:name],
                                   "type": params[:type],
                                   "expirationDate": params[:expiration_date]
                               }.to_json,content_type: :json, accept: :json)

      if response.code == 200
        @message = 'Element Created'
      else
        @message = "Element Failed to create error: #{response.body}"
      end
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured #{JSON.parse(e.response)['message']}"
    rescue StandardError => e
      @message = "Error occured #{e.message}"
    end
  end




end
