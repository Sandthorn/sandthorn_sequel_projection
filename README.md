# SandthornSequelProjection

A DSL and some convenience utilities for creating projections based on event data.
Uses the Sequel gem for storage.
 
Main points:

- Projections register themselves in a database table
- DSL for registering listeners to filtered event streams

## Installation

Add this line to your application's Gemfile:

    gem 'sandthorn_sequel_projection'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sandthorn_sequel_projection

## Usage

First do some basic configuration:

    SandthornSequelProjection.configure do |thorn|
      thorn.projection_database_url = "postgres://db-server.foo.bar"
      thorn.event_driver = SomeDriver.new
    end
    
Then create some projections

    class MyProjection < SandthornSequelProjection::Projection
    
      define_migration do |db_connection|
        # create whatever tables and stuff that is needed
      end
      
      event_listeners \
        new_users: { aggregate_type: MyAggregates::User, event_name: :new },
        foo_changed: { 
          aggregate_types: [MyAggregates::User, MyAggregates::Foo], 
          event_names: [:foo_changed, :bar_changed]
        }
      
      def new_users(event)
        # handle new user events, one at a time
      end
      
      def foo_changed(event)
        # handle the events defined in the foo_changed-listener, one at a time
      end
        
    end

When a Projection is defined it registers itself (in practice by writing to the DB).
This creates a shared repository of projections and negates the need to explicitly define what
projections to execute.
 
    
Then run the updater process. It will continuously poll for new events.

    $ rake sandthorn_sequel_projections:run
    # => Runs 'til Ragnarok

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sandthorn_sequel_projection/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
