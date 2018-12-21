class Element

  attr_reader :expiration_date, :creator, :name, :type, :creation_date, :id, :attributes, :location
  def initialize(id, type, name, location, attributes, creation, expiration, creator)
    @id = id
    @type = type
    @name = name
    @location = location
    @attributes = attributes
    @creation_date = creation
    @expiration_date = expiration
    @creator = creator
  end

  def print
    "Id: #{@id} Type: #{@type} Name: #{@name} Location: #{@location} Attributes #{attributes} \n
    Create Date: #{@creation_date} Expire Date: #{@expiration_date} Creator: #{@creator}"
  end



end