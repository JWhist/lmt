#admin class <-- who can access the program
class Admin
  def initialize(username, password)
    @username = username
    @password = password
  end

  def verify?; end
  def log_in; end
  def log_out; end
  def change_password; end
end
