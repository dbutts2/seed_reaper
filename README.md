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

The configuration passed to `SeedReaper::SeedWriter.new()` can be infilitely deep/complex and also accepts a `{ meta: { count: ... } }` hash at any level that will limit the number of seedified records, effectively subsetting a DB through the active record API.

## Copyright

Copyright (c) 2022 David Butts. See LICENSE.txt for
further details.
