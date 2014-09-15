# SandthornSequelProjection

A DSL and some convenience utilities for creating projections based on event data.
Uses the Sequel gem for storage.
 
Main points:

- DSL for registering event handlers that listen to filtered event streams
- Event handlers receive one event at a time
- Planned: projection manifests are used to declare dependent projections. This information can be used to execute
  non-dependent projections in parallel

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

### 1. Configure

    SandthornSequelProjection.configure do |thorn|
      thorn.projection_database_url = "postgres://db-server.foo.bar"
      thorn.event_driver = SomeDriver.new
      thorn.projections_folder = './my_projections'
    end
    
### 2. Define projections

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

### 3. Create a manifest

Manifests are used to define the order in which projections are run.

    manifest = SandthornSequelProjections::Manifest.create
      [
        MyProjection,
        MyProjections::SomeOtherProjection
      ]
  
### 4. Run the projections

Create a runner and give it the manifest. Run your projections.

    runner = SandthornSequelProjection::Runner.new(manifest)
    runner.run
    
The runner runs migrations for all of the projections and then 
polls the event store for changes and passes new events to the projections.

## Plans for the future

The projection manifest should define dependent projections, similar to how Rake tasks are defined.
In this way, we could identify the most efficient way of splitting up projections over multiple 
threads.

For example:

    SandthornSequelProjection.manifest do
      projection my_dependent_projection: [:projection_foo, :projection_bar]
      projection my_other_dependent_projection: [:my_dependent_projection, :projection_bar]
      projection my_third_dependent_projection: :projection_qux
    end

This manifest would create two independent branches:

    :projection_foo               :projection_bar               :projection_qux
              \                     /                                   |
             :my_dependent_projection                          :my_third_dependent_projection
                         |
                         |
           :my_other_dependent_projection
       
       
       


## Contributing

1. Fork it ( https://github.com/[my-github-username]/sandthorn_sequel_projection/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
