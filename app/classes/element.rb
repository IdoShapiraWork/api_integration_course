module Element

  require 'rest-client'


  def create_element
    @user = User.find_by_email(session[:user])
    location = {}
    attributes = set_attributes(params[:attributes])
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




  def get_elements_by_attribute
    begin
      response = RestClient.get("localhost:8086/playground/elements/#{@user.playground}/#{@user.email}/search/#{params[:search_value]}/#{params[:element_attribute]}")
      json_array = []
      objArray = JSON.parse(response.body)
      objArray.each do |json|
        json_array << json
      end
      @message = 'No Element Found' if objArray.length == 0
      @attr_elements =json_array
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured: Element not found"
    rescue StandardError => e
      @message =  "Error occured #{e}"
    end
  end

  def get_elements_by_location
    begin
      response = RestClient.get("localhost:8086/playground/elements/#{@user.playground}/#{@user.email}/near/#{params[:location_x]}/#{params[:location_y]}/#{params[:distance]}")
      json_array = []
      objArray = JSON.parse(response.body)
      @message = 'No Element Found' if objArray.length == 0
      objArray.each do |json|
        json_array << json
      end
      @location_elements =json_array
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured: Element not found"
    rescue StandardError => e
      @message = "#{e}"
    end
  end


  def get_element
    begin
      response = RestClient.get("localhost:8086/elementEntities/#{@user.playground}&#{params[:element_id]}")
      @element_edit = JSON.parse(response.body)
      @element_edit['attributes_print'] = ''
      @element_edit['attributes'].each do |h,v|
        @element_edit['attributes_print'] << "#{h}:#{v},"
      end
      @element_edit['attributes_print'] = @element_edit['attributes_print'][0..-2] # remove last comma
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
      response=RestClient.get("localhost:8086/playground/elements/#{@user.playground}/#{@user.email}/all?size=5&page=#{page}")
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

  def edit_element
    attributes = set_attributes(params[:element_attributes_edit])
    begin
      response = RestClient.put("localhost:8086/playground/elements/#{@user.playground}/#{@user.email}/#{@user.playground}/#{params[:element_id]}",{
          "playground": "2019a.Sapir",
          "id": params[:element_id],
          "location": { "x": params[:element_location_x_edit], "y": params[:element_location_y_edit] },
          "name": params[:name_element_edit],
          "creationDate": params[:element_create_date_edit],
          "expirationDate": params[:element_expiration_date_edit],
          "attributes": attributes,
          "creatorPlayground": @user.playground,
          "creatorEmail": @user.email
      }.to_json,content_type: :json, accept: :json)
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured: Element not found " +e.message
    rescue StandardError => e
      @message =  "Error occured #{e}"
    end
  end

  def set_attributes(form_attributes)
    attributes = {}
    attributes_data = form_attributes.split(',')
    attributes_data.each do |data|
      attr=data.split(':')
      attributes[attr[0]] = attr[1]
    end
    attributes
  end


end