[![Build Status](https://secure.travis-ci.org/FineLinePrototyping/undeletable.png?branch=master)][travis] [![Gem Version](https://badge.fury.io/rb/undeletable.png)][badgefury]

# Undeletable

`undeletable` on the model class disables the ability to `delete`/`destroy` on instance, model class, and via relation, using the default ActiveRecord version of those, and supports destroy callbacks if raise not enabled. `undeletable!` on the model class will raise an error when those are attempted. `destroy!` in Rails 4 is supported.

Tested with ActiveRecord 3.1.x, 3.2.x, and 4.0.x via travis and appraisal.

Code originally based on [Paranoia][paranoia] (by Ryan Bigg and others), but extremely modified to the point it really shares little in common now.

## Installation & Usage

Put this in your Gemfile:

```ruby
gem 'undeletable'
```

Then run:

```shell
bundle install
```

Updating is as simple as `bundle update undeletable`.

### Usage

#### In your environment.rb:

```ruby
Undeletable.configure do
  # if true, debug log failed attempts to delete/destroy when not raising error
  self.debug = false
end

...
```

#### In your model:

To silently disallow attempts to delete/destroy:

```ruby
class Client < ActiveRecord::Base
  undeletable

  ...
end
```

To disallow attempts to delete/destroy, but raise ActiveRecord::ReadOnlyRecord on attempts:

```ruby
class Client < ActiveRecord::Base
  undeletable!

  ...
end
```

## Upgrading

* v0.0.1 -> v1.0.x: `delete!` and `destroy!` no longer supported for now. `destroy!` has a Rails 4 naming conflict with same named method, and attempting to provide support for ActiveRecord::Relation made it too complicated for now (problems with infinite recursion requiring more state to setup and check, etc.). If you need to delete or destroy an undeletable model, the workaround is to comment the undeletable method on the class.

## License

This gem is released under the [MIT license][lic].

[lic]: http://github.com/FineLinePrototyping/undeletable/blob/master/LICENSE
[paranoia]: https://github.com/radar/paranoia
[travis]: http://travis-ci.org/FineLinePrototyping/undeletable
[badgefury]: http://badge.fury.io/rb/undeletable
