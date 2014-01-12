class SimiliarTrips

  include DataMapper::Resource

  property :id, Serial

  property :trip_id, Integer
  property :other_trip_id, Integer
  property :start_distance, Integer
  property :end_distance, Integer

end
