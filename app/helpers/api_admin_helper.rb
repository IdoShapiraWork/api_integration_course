module ApiAdminHelper
  require 'rest-client'

  def get_elements(page,records_per_age)
    json_array = []
    begin
      response=RestClient.get("localhost:8086/playground/elements/#{@user.playground}/#{@user.email}/all?size=#{records_per_age}&page=#{page-1}")
    objArray = JSON.parse(response.body)

    if objArray.length == 0
      return nil
    else
      objArray.each do |json|
        json_array << json
      end
      page += 1
    end
    json_array.to_json
    rescue StandardError => e
      puts e.message
    end
  end

end
