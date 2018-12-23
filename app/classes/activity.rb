module Activity

  require 'rest-client'

  def create_message
    begin
      response = RestClient.get("localhost:8086/elementEntities/#{@user.playground}&#{params[:element_id]}") # test element
      element = JSON.parse(response.body)
      if element['type'] == 'bulletinBoard' # post only if bulletin board type
        RestClient.post("localhost:8086/playground/activities/2019a.Sapir/ido@gmail.com",
                        {
                            "type": 'PostMsg',
                            "playerEmail": @user.email,
                            "elementId": params[:element_id],
                            "elementPlayground": @user.playground,
                            "playerPlayground": @user.playground,
                            "attributes": {
                                "message": params[:message_body]
                            }
                        }.to_json, content_type: :json, accept: :json)
        @message = 'Message Posted Successfully'
      else
        @message = 'Element type is not bulletin board'
      end

    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured Element not found #{e}"
    rescue StandardError => e
      @message = "Error occured #{e.message}"
    end
  end

  def view_messages

  end

end

=begin

"type": "PostMsg",
"playerEmail": "test@gmail.com",
"elementId": "bulletinBoardElementId",
"elementPlayground": "2019a.Sapir",
"playerPlayground": "2019a.Sapir",
"attributes":	{
"message": "AnyMessage"
}


=end