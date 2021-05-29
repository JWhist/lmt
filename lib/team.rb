#team class
class Team
  attr_reader :name, :coach, :roster

  def initialize(name, coaches = [])
    @name = name
    @coaches = coaches
    @roster = []
  end

  def add_player; end
  def drop_player; end
  def edit_players; end
  def add_coach; end
  def drop_coach; end
  def edit_coach; end
end