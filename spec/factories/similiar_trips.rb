# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :similiar_trip, :class => 'SimiliarTrips' do
    trip_id 1
    other_trip_id 1
    start_distance 1
    end_distance 1
  end
end
