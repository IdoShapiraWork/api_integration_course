class ApiAdminController < ApplicationController
  require 'rest-client'
  def api_admin
    @message = ''
    @user = User.find_by_email(session[:user])
    @elements = get_all_elements
    unless params[:request_type].blank?
      case params[:request_type]

      when 'create_element'
        create_element
      end

    end
    respond_to do |format|
      format.html
      format.js
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
        json_array+= objArray
        page += 1
      end
    end
    json_array
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
                                   "type": params[:type]
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
