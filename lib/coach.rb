#coach class
class Coach
  attr_reader :name, :email, :phone, :team, :sport

  def initialize(name, email = '', phone = 9999999999)
    @name = name
    @email = email
    @phone = phone
  end

  def edit_contact_info(info = {}); end
  def view_roster; end
  def send_mail; end
  def view_schedule; end
end