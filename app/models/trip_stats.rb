class TripStats

  include DataMapper::Resource

  property :id, Serial
  property :trips_within_2_km, Integer

  belongs_to :intended_trip

  before :valid?, :update_stats

  def update_stats
    self.trips_within_2_km = intended_trip.trips_within(2000).count
  end

  def self.update_for(trip)
    TripStats.first_or_new(:intended_trip => trip).save
    trip.trips_within(2000).each{|t| TripStats.first_or_new(:intended_trip_id => t[:id]).save }
  end



end
