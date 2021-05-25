#game class
class Game
  attr_reader :home_team, :away_team, :date, :score, :venue

  def initialize(home, away, date = Time.new, venue = '')
    @home_team = home
    @away_team = away
    @date = date
    @venue = venue
  end

  def edit_teams(teams = {}); end
  def edit_date(new_date); end
  def edit_venue(new_venue); end
end