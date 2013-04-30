# Undeletable

The `undeletable` class method disables the ability to `delete`/`destroy` an ActiveRecord model instance, and `undeletable!` raises an error if a `delete`/`destroy!` is attempted. Can support destroy callbacks if raise not enabled.

Similar to paranoid/acts_as_paranoid, the bang methods, `destroy!` and `delete!` are provided in case the original destroy/delete methods are needed.

Undeletable is a fork of [Paranoia][paranoia] (by Ryan Bigg and others) but heavily modified to just disallow normal deletion.

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

## License

This gem is released under the MIT license.

[paranoia]: https://github.com/radar/paranoia
