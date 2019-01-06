module Activity

  require 'rest-client'

  def create_message
    begin
      response = RestClient.get("localhost:8086/elementEntities/#{@user.playground}&#{params[:element_id]}") # test element
      element = JSON.parse(response.body)
      if element['type'] == 'bulletinBoard' # post only if bulletin board type
        RestClient.post("localhost:8086/playground/activities/2019a.Sapir/#{@user.email}",
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
    begin
      response = RestClient.get("localhost:8086/elementEntities/#{@user.playground}&#{params[:element_id]}") # test element
      element = JSON.parse(response.body)
      if element['type'] == 'bulletinBoard' # post only if bulletin board type
        response=RestClient.post("localhost:8086/playground/activities/#{@user.playground}/#{@user.email}",
                        {
                            "type": 'ViewMsg',
                            "playerEmail": @user.email,
                            "elementId": params[:element_id],
                            "elementPlayground": @user.playground,
                            "playerPlayground": @user.playground,
                        }.to_json, content_type: :json, accept: :json)
        messages = JSON.parse(response.body)
        puts messages
        messages['messages'].each do |row|
          hash = JSON.parse(row)
          puts hash
          @view_board_messages.push("Message: #{hash['message']}")
        end
        @view_board_messages
      else
        @message = 'Element type is not bulletin board'
      end
    rescue RestClient::ExceptionWithResponse => e
      @message = "Error occured Element not found #{e}"
    rescue StandardError => e
      @message = "Error occured #{e.message}"
    end

  end

  def update_attendance
    begin


    response = RestClient.get("localhost:8086/elementEntities/#{@user.playground}&#{params[:element_id]}") # test element
    puts response.body
    element = JSON.parse(response.body)
    if element['type'] == 'attendanceSheet' # post only if attendance Sheet
      response=RestClient.post("localhost:8086/playground/activities/#{@user.playground}/#{@user.email}",
                               {
                                   "type": 'Attendance',
                                   "playerEmail": @user.email,
                                   "elementId": params[:element_id],
                                   "elementPlayground": @user.playground,
                                   "playerPlayground": @user.playground,
                                   "attributes": {
                                       "totalStudentNumber": params[:students_listed].to_i,
                                       "attendanceStudentNumber": params[:students_arrived].to_i
                                   }
                               }.to_json, content_type: :json, accept: :json)
      message = JSON.parse(response.body)
      @user.points = message['points']
      @user.save
      @message = "Attendance Updated! Your total amount of points is: #{@user.points}"
    else
      @message = 'Element inserted is not an attendnace sheet'
    end
    rescue
      @message = 'Element not found'
    end
  end

end

=begin

Post /playground/activities/2019a.Sapir/test@gmail.com
	with body: {
"type": "Attendance",
"playerEmail": "test@gmail.com",
"elementId": "attendanceSheetElementId",
"elementPlayground": "2019a.Sapir",
"playerPlayground": "2019a.Sapir",
"attributes":	{
"totalStudentNumber": "AnyNumber",
"attendanceStudentNumber": "NumberGreaterThanTotalStudentNumber"
}
}



=end