# seed_reaper (under development)

Subsetter and object to seed serializer.

## Install

`gem 'seed_reaper'`

## Usage

Lets say you have the following:

```
class Thing < ActiveRecord::Base
  has_many :associated_things
end

class AssociatedThing < ActiveRecord::Base
  belongs_to :thing
end
```

This:

`SeedReaper::SeedWriter.new(thing: :associated_things).write!`

Will produce:

```
# db/seeds/0_thing.seeds.rb

Thing.new(
  # ...attributes
).save!(validate: false)

AssociatedThing.new(
  # ...attributes
).save!(validate: false)

# ... the rest of the associated_things
```

The configuration passed to `SeedReaper::SeedWriter.new()` can be infilitely deep/complex and also accepts a `{ meta: { count: ... } }` hash at any level that will limit the number of seedified records, effectively subsetting a DB through the active record API. The configuration passed must be a list/array at the root level and can be as granular as necessary.

## Realistic Example

```
SeedReaper::SeedWriter.new(
  :industry,
  :service_provider_category,
  :service_location,
  :auto_added_service,
  :green_industry,
  {
    base_service_provider: [
      { meta: { count: 10 } },
      :contact,
      :human_resources_contact
    ]
  },
  {
    user: [
      { meta: { count: 50, joins: :admin } },
      :admin,
      {
        contact: [
          :contact_infos
        ]
      }
    ]
  }
).write!
```

Note that order is significant. The seeds are serialized using `.save!(validate: false)` but this will obviously not subvert the DB schema constraints in the case of foreign keys etc. I.e. if `industries` had a foreign key constraint to `service_provider_categories`, for instance, you would likely want to flip those arround in the list so that the dependency is seeded first (the seed files are prefixed with integers to enforce this during `db:seed`).

## Copyright

Copyright (c) 2022 David Butts. See LICENSE.txt for
further details.
