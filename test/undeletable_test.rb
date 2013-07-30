require 'test/unit'
require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/../lib/undeletable")

DB_FILE = 'tmp/test_db'

FileUtils.mkdir_p File.dirname DB_FILE
FileUtils.rm_f DB_FILE

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE
ActiveRecord::Base.connection.execute 'CREATE TABLE parent_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE undeletable_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE featureful_models (id INTEGER NOT NULL PRIMARY KEY, name VARCHAR(32))'
ActiveRecord::Base.connection.execute 'CREATE TABLE child_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER)'
ActiveRecord::Base.connection.execute 'CREATE TABLE plain_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE callback_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE related_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER NOT NULL)'
ActiveRecord::Base.connection.execute 'CREATE TABLE employers (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE employees (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE jobs (id INTEGER NOT NULL PRIMARY KEY, employer_id INTEGER NOT NULL, employee_id INTEGER NOT NULL)'
ActiveRecord::Base.connection.execute 'CREATE TABLE undeletable_bang_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER)'
ActiveRecord::Base.connection.execute 'CREATE TABLE featureful_bang_models (id INTEGER NOT NULL PRIMARY KEY, name VARCHAR(32))'

class UndeletableTest < Test::Unit::TestCase

  def setup
    ActiveRecord::Base.connection.execute 'DELETE FROM parent_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM undeletable_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM featureful_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM child_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM plain_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM callback_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM related_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM employers'
    ActiveRecord::Base.connection.execute 'DELETE FROM employees'
    ActiveRecord::Base.connection.execute 'DELETE FROM jobs'
    ActiveRecord::Base.connection.execute 'DELETE FROM undeletable_bang_models'
    ActiveRecord::Base.connection.execute 'DELETE FROM featureful_bang_models'
  end

  # plain/unaltered

  def test_plain_class_has_delete
    assert_equal true,  PlainModel.respond_to?(:delete)
  end

  def test_plain_class_has_delete_all
    assert_equal true,  PlainModel.respond_to?(:delete_all)
  end

  def test_plain_instance_has_delete
    assert_equal true,  PlainModel.new.respond_to?(:delete)
  end

  def test_plain_instance_has_destroy
    assert_equal true,  PlainModel.new.respond_to?(:destroy)
  end

  def test_plain_class_does_not_have_force_delete
    assert_equal false, PlainModel.respond_to?(:force_delete), "Did not expect PlainModel class to have force_destroy method: #{PlainModel.method(:force_destroy)}"
  rescue NameError
  end

  def test_plain_class_does_not_have_force_delete_all
    assert_equal false, PlainModel.respond_to?(:force_delete_all), "Did not expect PlainModel class to have force_delete_all method: #{PlainModel.method(:force_delete_all)}"
  rescue NameError
  end

  def test_plain_instance_does_not_have_force_delete
    assert_equal false, PlainModel.new.respond_to?(:force_delete), "Did not expect PlainModel instance to have force_delete method: #{PlainModel.new.method(:force_delete)}"
  rescue NameError
  end

  def test_plain_instance_does_not_have_force_destroy
    assert_equal false, PlainModel.new.respond_to?(:force_destroy), "Did not expect PlainModel instance to have force_destroy method: #{PlainModel.new.method(:force_destroy)}"
  rescue NameError
  end

  def test_plain_model_instance_is_not_marked_undeletable
    assert_equal false, PlainModel.new.undeletable?
  end

  def test_plain_model_class_is_not_marked_undeletable
    assert_equal false, PlainModel.undeletable?
  end

  # undeletable

  def test_undeletable_class_has_force_delete
    assert_equal true,  UndeletableModel.respond_to?(:force_delete)
  end

  def test_undeletable_class_has_force_delete_all
    assert_equal true,  UndeletableModel.respond_to?(:force_delete_all)
  end

  def test_undeletable_instance_has_force_delete
    assert_equal true,  UndeletableModel.new.respond_to?(:force_delete)
  end

  def test_undeletable_instance_has_force_destroy
    assert_equal true,  UndeletableModel.new.respond_to?(:force_destroy)
  end
  
  def test_undeletable_model_instance_is_marked_undeletable
    assert_equal true, UndeletableModel.new.undeletable?
  end

  def test_undeletable_model_class_is_marked_undeletable
    assert_equal true, UndeletableModel.undeletable?
  end

  def test_undeletable_instance_delete
    model = UndeletableModel.new
    assert_equal 0, model.class.count
    model.save
    assert_equal 1, model.class.count
    model.delete
    assert_equal 1, model.class.count
  end

  def test_undeletable_instance_destroy
    model = UndeletableModel.new
    assert_equal 0, model.class.count
    model.save
    assert_equal 1, model.class.count
    model.destroy
    assert_equal 1, model.class.count
  end

  def test_undeletable_instance_destroy_bang_if_supported
    # destroy! implemented in Rails 4
    unless UndeletableModel.new.respond_to?(:destroy!)
      # skipping because model.destroy! not implemented
      return
    end

    begin
      model = UndeletableModel.new
      assert_equal 0, model.class.count
      model.save
      assert_equal 1, model.class.count
      # Rails 4 raises ActiveRecord::RecordNotDestroyed
      model.destroy!
      fail "should raise ActiveRecord::RecordNotDestroyed. destroy! implemented in #{model.method(:destroy!)}"
    rescue ActiveRecord::RecordNotDestroyed
      assert_equal 1, model.class.count
    end
  end

  def test_undeletable_class_delete
    model = UndeletableModel.new
    assert_equal 0, model.class.count
    model.save
    assert_equal 1, model.class.count
    UndeletableModel.delete(model.id)
    assert_equal 1, model.class.count
  end

  def test_undeletable_class_delete_all
    model = UndeletableModel.new
    assert_equal 0, model.class.count
    model.save
    assert_equal 1, model.class.count
    UndeletableModel.delete_all
    assert_equal 1, model.class.count
  end

  def test_undeletable_to_param_destroy
    model = UndeletableModel.new
    assert_equal 0, model.class.count
    model.save
    to_param = model.to_param
    assert_equal 1, model.class.count
    model.destroy
    assert_not_equal nil, model.to_param
    assert_equal to_param, model.to_param
  end

  def test_undeletable_scoping
    parent1 = ParentModel.create
    parent2 = ParentModel.create
    p1 = ChildModel.create(:parent_model => parent1)
    p2 = ChildModel.create(:parent_model => parent2)
    p1.destroy
    p2.destroy
    assert_equal 1, parent1.child_models.count
    p3 = ChildModel.create(:parent_model => parent1)
    assert_equal 2, parent1.child_models.count
    assert_equal [p1,p3], parent1.child_models
  end

  def test_undeletable_featureful_destroy
    model = FeaturefulModel.new(:name => "not empty")
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    assert_equal 1, model.class.count
  end

  def test_has_many_destroy
    parent = ParentModel.create
    assert_equal 0, parent.related_models.count
    child = parent.related_models.create
    assert_equal 1, parent.related_models.count
    child.destroy
    assert_equal 1, parent.related_models.count
  end

  def test_has_many_through_destroy
    employer = Employer.create
    employee = Employee.create
    assert_equal 0, employer.jobs.count
    assert_equal 0, employer.employees.count
    assert_equal 0, employee.jobs.count
    assert_equal 0, employee.employers.count
    job = Job.create :employer => employer, :employee => employee
    assert_equal 1, employer.jobs.count
    assert_equal 1, employer.employees.count
    assert_equal 1, employee.jobs.count
    assert_equal 1, employee.employers.count
    employee2 = Employee.create
    job2 = Job.create :employer => employer, :employee => employee2
    employee2.destroy
    assert_equal 2, employer.jobs.count
    assert_equal 2, employer.employees.count
    job.destroy
    assert_equal 2, employer.jobs.count
    assert_equal 2, employer.employees.count
  end

  def test_no_callback_on_instance_delete
    model = CallbackModel.new
    model.save
    model.delete
    assert_equal nil, model.instance_variable_get(:@callback_called)
  end

  def test_does_callback_on_instance_destroy
    model = CallbackModel.new
    model.save
    model.destroy
    assert model.instance_variable_get(:@callback_called)
  end

  # undeletable - force_* methods

  def test_undeletable_force_delete
    model = UndeletableModel.new
    model.save
    assert_equal 1, model.class.count
    model.force_delete
    assert_equal 0, model.class.count, "force_delete didn't delete as expected. implemented in #{model.method(:force_delete)}"
  end

  def test_undeletable_force_destroy
    model = UndeletableModel.new
    model.save
    assert_equal 1, model.class.count
    model.force_destroy
    assert_equal 0, model.class.count
  end

  def test_undeletable_class_force_delete
    model = UndeletableModel.new
    model.save
    assert_equal 1, model.class.count
    model.class.force_delete(model.id)
    assert_equal 0, model.class.count
  end

  def test_undeletable_class_force_delete_all
    model = UndeletableModel.new
    model.save
    assert_equal 1, model.class.count
    model.class.force_delete_all
    assert_equal 0, model.class.count
  end

  # undeletable!

  def test_undeletable_bang_model_instance_id_marked_undeletable
    assert_equal true, UndeletableBangModel.new.undeletable?
  end
  
  def test_undeletable_bang_model_class_is_marked_undeletable
    assert_equal true, UndeletableBangModel.undeletable?
  end

  def test_undeletable_bang_destroy
    model = UndeletableBangModel.new
    model.save
    assert_equal 1, model.class.count
    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

  def test_undeletable_bang_instance_destroy_bang_if_implemented
    # destroy! implemented in Rails 4
    unless UndeletableModel.new.respond_to?(:destroy!)
      # skipping because model.destroy! not implemented
      return
    end

    begin
      model = UndeletableBangModel.new
      assert_equal 0, model.class.count
      model.save
      assert_equal 1, model.class.count
      # Rails 4 raises ActiveRecord::RecordNotDestroyed
      model.destroy!
      fail "should raise ActiveRecord::RecordNotDestroyed"
    rescue ActiveRecord::RecordNotDestroyed
      assert_equal 1, model.class.count
    end
  end

  def test_undeletable_bang_delete
    model = UndeletableBangModel.new
    model.save
    assert_equal 1, model.class.count
    model.delete
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

  def test_undeletable_bang_class_delete
    model = UndeletableBangModel.new
    model.save
    assert_equal 1, model.class.count
    UndeletableBangModel.delete(model.id)
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

  def test_undeletable_bang_class_delete_all
    model = UndeletableBangModel.new
    model.save
    assert_equal 1, model.class.count
    UndeletableBangModel.delete_all
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

  def test_undeletable_bang_models_to_param
    model = UndeletableBangModel.new
    model.save
    to_param = model.to_param
    assert_equal 1, model.class.count
    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

  def test_destroy_behavior_for_undeletable_bang_models
    model = UndeletableBangModel.new
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

  def test_destroy_behavior_for_featureful_undeletable_bang_models
    model = FeaturefulBangModel.new(:name => "not empty")
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
    assert_equal 1, model.class.count
  end

end

# Helper classes

class PlainModel < ActiveRecord::Base
end

class ParentModel < ActiveRecord::Base
  undeletable
  has_many :related_models
  has_many :child_models
end

class ChildModel < ActiveRecord::Base
  belongs_to :parent_model
  undeletable
end

class RelatedModel < ActiveRecord::Base
  undeletable
  belongs_to :parent_model
end

class Employer < ActiveRecord::Base
  undeletable
  has_many :jobs
  has_many :employees, :through => :jobs
end

class Employee < ActiveRecord::Base
  undeletable
  has_many :jobs
  has_many :employers, :through => :jobs
end

class Job < ActiveRecord::Base
  undeletable
  belongs_to :employer
  belongs_to :employee
end

class UndeletableModel < ActiveRecord::Base
  undeletable
end

class FeaturefulModel < ActiveRecord::Base
  undeletable
  validates :name, :presence => true, :uniqueness => true
end

class CallbackModel < ActiveRecord::Base
  undeletable
  before_destroy {|model| model.instance_variable_set :@callback_called, true }
end

class UndeletableBangModel < ActiveRecord::Base
  undeletable!
end

class FeaturefulBangModel < ActiveRecord::Base
  undeletable!
  validates :name, :presence => true, :uniqueness => true
end
