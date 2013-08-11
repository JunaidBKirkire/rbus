require 'dm-types'

migration 1, :create_extensions do

  up do
    execute "CREATE EXTENSION IF NOT EXISTS cube"
    execute "CREATE EXTENSION IF NOT EXISTS earthdistance"
  end

end


migration 2, :drop_extra_columns do

  up do
    execute "ALTER TABLE intended_trips DROP COLUMN fdist"
    execute "ALTER TABLE intended_trips DROP COLUMN tdist"
  end

end
