# SandthornSequelProjection

A DSL and some convenience utilities for creating projections based on event data.
Uses the Sequel gem for storage.
 
Main points:

- Projections are placed in a projections folder for easy access
- DSL for registering listeners to filtered event streams

Requirements on event handling:

- It must be possible to define event handlers such that the execution order is defined

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
      thorn.projections_folder = './my_projections'
    end
    
Then create some projections

    class MyProjection < SandthornSequelProjection::Projection
    
      define_migration do |db_connection|
        # create whatever tables and stuff that is needed
      end
      
      # Event handlers will be executed in the order they were defined
      # The key is the name of the method to be executed. Filters are defined in the value.
      # Handlers with only a symbol will execute for all events.
      define_event_handlers do |handlers|
        handlers.add new_user: { aggregate_type: MyAggregates::User, event_name: :new }
        handlers.add foo_changed: { aggregate_types: [MyAggregates::User, MyAggregates::Foo] }
        handlers.add :wildcard
      end 
        
      def new_users(event)
        # handle new user events, one at a time
      end
      
      def foo_changed(event)
        # handle the events defined in the foo_changed-listener, one at a time
      end
      
      def wildcard(event)
        # Will receive all events
      end
    end
   
Then run the runner, for example by putting it in a rake task

    runner = SandthornSequelProjection::Runner.new
    runner.run
    
The runner polls the database for changes and passes new events to the projections found in the designated 
projections folder.
    
Then run the updater process. It will continuously poll for new events.

    $ rake sandthorn_sequel_projections:run
    # => Runs 'til Ragnarok

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sandthorn_sequel_projection/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
