class IntendedTrip
  include DataMapper::Resource
  property :id, Serial

  property :on, Enum["weekdays", "weekdays and saturday", "all days"], :required => true

  property :from_name, String, :required => true, :length => 150;
  property :from_lat, Decimal, :precision => 18, :scale => 15, :required => true, :max => 90, :min => -90
  property :from_lng, Decimal, :precision => 18, :scale => 15, :required => true, :max => 90, :min => -90

  property :to_name, String, :required => true, :length => 150;
  property :to_lat, Decimal, :precision => 18, :scale => 15, :required => true, :max => 90, :min => -90
  property :to_lng, Decimal, :precision => 18, :scale => 15, :required => true, :max => 90, :min => -90

  property :type, String

  belongs_to :user

  property :created_at, DateTime
  property :updated_at, DateTime
  property :deleted_at, ParanoidDateTime


  # accepts_nested_attributes_for :user

  # Public: finds all the trips starting and ending within a particular radius of this trip
  # meters -> the radius within which to search. currently returns trips where the sum of the start distance and end distance is less than this parameter
  def trips_within(meters)
    f = distance(:from)
    t = distance(:to)
    trips_with_distance.where{(f + t <= meters)}.exclude(:id => self.id).all
  end

  # Public: gets the nearest trips, sorted by a given order
  # params     ->  a Hash with keys for limit and offset. Defaults to {:limit => 20, :offset => 0}
  # sort_order -> one of :from, :to or :total, specifying whether to sort on distance at start, distance at end or total distance. Defaults to :total
  def nearest_trips(params = {}, sort_order = :total)
    params = {:limit => 100, :offset => 0}.merge(params)
    sorted_trips = trips_with_distance.order(distance(:from) + distance(:to))
    sorted_trips.map{|t| {
        :trip => IntendedTrip.get(t[:id]),
        :start_distance => t[:fdist],
        :end_distance => t[:tdist],
        :total_distance => t[:fdist] + t[:tdist]
      } unless t[:id] == self.id}.compact.select{|x| x[:trip]}
  end


  # Public: return trips that match the given lat/lng filters
  # options  -> a Hash with the following keys
  #     from ->  a Hash with keys lat1, lng1, lat2, lng2 representing the coordinates within which the trip must start
  #     to   ->  a Hash with keys lat1, lng1, lat2, lng2 representing the coordinates within which the trip must start
  # returns a DataMapper::Collection of IntendedTrips
  # example: Trip.filter(:from => {:lat1 => 19, :lng1 => 72, :lat2 => 20, :lng2 => 73})
  def self.filter(options = nil)
    return self.all unless options
    q = {}
    if f = options[:from]
      q[:from_lat.gte] = f[:lat1]
      q[:from_lng.gte] = f[:lng1]
      q[:from_lat.lte] = f[:lat2]
      q[:from_lng.lte] = f[:lng2]
    end
    if t = options[:to]
      q[:to_lat.gte] = t[:lat1]
      q[:to_lng.gte] = t[:lng1]
      q[:to_lat.lte] = t[:lat2]
      q[:to_lng.lte] = t[:lng2]
    end
    self.all(q)
  end

  def inspect
    "[#{id}: from #{from_name}(#{from_lat},#{from_lng}) to #{to_name}(#{to_lat},#{to_lng}) on #{on}]"
  end

  # Returns similiar trips to the trip being passed. We only select those trips whose start, end points are within kilometre of the
  # start and end points of the trip being passed.
  def similiar_trips( new_trip )
    similiar_trips = DB[ :intended_trips ].
        select(
                Sequel.as( new_trip[ :id ], "trip_id" ),
                Sequel.as( :id, "other_trip_id" ),
                Sequel.as( Sequel.lit( "(? <@> ?)*1609", Sequel.function( :POINT, new_trip[ :from_lng ], new_trip[ :from_lat ]), Sequel.function( :POINT, :from_lng, :from_lat ) ), "start_dist" ),
                Sequel.as( Sequel.lit( "(? <@> ?)*1609", Sequel.function( :POINT, new_trip[ :to_lng ], new_trip[ :to_lat ]), Sequel.function( :POINT, :to_lng, :to_lat ) ), "to_dist" )
        ).
        where("earth_box( ll_to_earth( #{new_trip[ :from_lat ]}, #{new_trip[ :from_lng ]} ), 1000 ) @> ll_to_earth( from_lat, from_lng ) and earth_box( ll_to_earth(#{new_trip[ :to_lat ]}, #{new_trip[ :to_lng ]}), 1000  ) @> ll_to_earth( to_lat, to_lng )").exclude( :id => new_trip[ :id ])

  DB[ :similiar_trips ].where( :trip_id => new_trip[ :id ] ).delete
  DB[ :similiar_trips ].import( [ :trip_id, :other_trip_id, :start_distance, :end_distance] , similiar_trips)
    
  end

  private

  # Returns all the other trips in the database with their fdist and tdist calculated
  def trips_with_distance
    DB[:intended_trips].select(:id, :from_name, :to_name,
                               :from_lat, :from_lng,
                               :to_lat, :to_lng,
                               distance(:from).as(:fdist),
                               distance(:to).as(:tdist)
                               ).where(:deleted_at => nil)
  end

  # Returns a Sequel.function to calculate the distance between a trip and all other trips
  def distance(what)
    lat, lng = "#{what}_lat".to_sym, "#{what}_lng".to_sym
    Sequel.function(:earth_distance,
                    Sequel.function(:ll_to_earth, self.send(lat), self.send(lng)),
                    Sequel.function(:ll_to_earth, lat, lng)
                    )
  end


end
