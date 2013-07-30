[![Build Status](https://secure.travis-ci.org/FineLinePrototyping/undeletable.png?branch=master)][travis] [![Gem Version](https://badge.fury.io/rb/undeletable.png)][badgefury]

# Undeletable

The `undeletable` class method disables the ability to `delete`/`destroy`. The `undeletable!` class method is similar, but raises an error when those are attempted. Can support destroy callbacks if raise not enabled. Supports Rails 4 and it's new `destroy!` method.

You can still override via prefixing the method name with `force_`, e.g. `force_destroy`/`force_delete`/`force_delete_all`.

This gem is tested against ActiveRecord 3.1.x, 3.2.x, and 4.0.x.

Undeletable was originally based on [Paranoia][paranoia] (by Ryan Bigg and others), but very heavily modified.

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

* v0.0.1 -> v1.0.x: instead of using `delete!` and `destroy!`, use `force_delete` and `force_destroy`. This is because ActiveRecord v4 now has a [destroy!][rails4_destroy] method, and it made sense to avoid conflicts.

## License

This gem is released under the [MIT license][lic].

[lic]: http://github.com/FineLinePrototyping/undeletable/blob/master/LICENSE
[rails4_destroy]: https://github.com/rails/rails/blob/v4.0.0/activerecord/lib/active_record/persistence.rb#L169
[paranoia]: https://github.com/radar/paranoia
[travis]: http://travis-ci.org/FineLinePrototyping/undeletable
[badgefury]: http://badge.fury.io/rb/undeletable
