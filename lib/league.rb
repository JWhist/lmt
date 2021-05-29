#league class
class League
  attr_reader :name, :teams

  def initialize(name)
    @name = name
    @teams = []
  end

  def add_team(team)
    @teams.push(team)
  end
 
  def drop_team(team)
    @teams.delete(team)
  end

  def edit_teams; end
end