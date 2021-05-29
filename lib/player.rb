#player class
class Player
  attr_reader :name, :email, :phone, :team, :sport

  def initialize(name, email = '', phone = 9999999999)
    @name = name
    @email = email
    @phone = phone
  end

  def edit_contact_info(info = {}); end
end