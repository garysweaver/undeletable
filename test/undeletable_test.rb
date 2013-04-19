require 'test/unit'
require 'active_record'
require File.expand_path(File.dirname(__FILE__) + "/../lib/undeletable")

DB_FILE = 'tmp/test_db'

FileUtils.mkdir_p File.dirname(DB_FILE)
FileUtils.rm_f DB_FILE

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => DB_FILE
ActiveRecord::Base.connection.execute 'CREATE TABLE parent_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE undeletable_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER)'
ActiveRecord::Base.connection.execute 'CREATE TABLE featureful_models (id INTEGER NOT NULL PRIMARY KEY, name VARCHAR(32))'
ActiveRecord::Base.connection.execute 'CREATE TABLE plain_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE callback_models (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE related_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER NOT NULL)'
ActiveRecord::Base.connection.execute 'CREATE TABLE employers (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE employees (id INTEGER NOT NULL PRIMARY KEY)'
ActiveRecord::Base.connection.execute 'CREATE TABLE jobs (id INTEGER NOT NULL PRIMARY KEY, employer_id INTEGER NOT NULL, employee_id INTEGER NOT NULL)'

ActiveRecord::Base.connection.execute 'CREATE TABLE undeletable_bang_models (id INTEGER NOT NULL PRIMARY KEY, parent_model_id INTEGER)'
ActiveRecord::Base.connection.execute 'CREATE TABLE featureful_bang_models (id INTEGER NOT NULL PRIMARY KEY, name VARCHAR(32))'

class UndeletableTest < Test::Unit::TestCase
  def test_plain_model_class_is_not_undeletable
    assert_equal false, PlainModel.undeletable?
  end

  def test_undeletable_model_class_is_undeletable
    assert_equal true, UndeletableModel.undeletable?
  end

  def test_plain_models_are_not_undeletable
    assert_equal false, PlainModel.new.undeletable?
  end

  def test_undeletable_models_are_undeletable
    assert_equal true, UndeletableModel.new.undeletable?
  end

  def test_undeletable_models_to_param
    model = UndeletableModel.new
    model.save
    to_param = model.to_param

    model.destroy

    assert_not_equal nil, model.to_param
    assert_equal to_param, model.to_param
  end

  def test_destroy_behavior_for_plain_models
    model = PlainModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    assert_equal 0, model.class.count

  end

  def test_destroy_behavior_for_undeletable_models
    UndeletableModel.delete_all
    model = UndeletableModel.new
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    assert_equal 1, model.class.count
  end
  
  def test_scoping_behavior_for_undeletable_models
    UndeletableModel.delete_all
    parent1 = ParentModel.create
    parent2 = ParentModel.create
    p1 = UndeletableModel.create(:parent_model => parent1)
    p2 = UndeletableModel.create(:parent_model => parent2)
    p1.destroy
    p2.destroy
    assert_equal 1, parent1.undeletable_models.count
    p3 = UndeletableModel.create(:parent_model => parent1)
    assert_equal 2, parent1.undeletable_models.count
    assert_equal [p1,p3], parent1.undeletable_models
  end

  def test_destroy_behavior_for_featureful_undeletable_models
    model = get_featureful_model
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    assert_equal 1, model.class.count
  end

  def test_has_many_relationships
    parent = ParentModel.create
    assert_equal 0, parent.related_models.count

    child = parent.related_models.create
    assert_equal 1, parent.related_models.count

    child.destroy

    assert_equal 1, parent.related_models.count
  end

  def test_has_many_through_relationships
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

  def test_delete_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    model.delete
    assert_equal nil, model.instance_variable_get(:@callback_called)
  end

  def test_destroy_behavior_for_callbacks
    model = CallbackModel.new
    model.save
    model.destroy
    assert model.instance_variable_get(:@callback_called)
  end

  def test_real_destroy
    model = UndeletableModel.new
    model.save
    model.destroy!

    assert_equal false, UndeletableModel.exists?(model.id)
  end

  def test_real_delete
    model = UndeletableModel.new
    model.save
    model.delete!

    assert_equal false, UndeletableModel.exists?(model.id)
  end

  # Bang method tests

  def test_undeletable_bang_model_class_is_undeletable
    assert_equal true, UndeletableBangModel.undeletable?
  end

  def test_undeletable_bang_models_are_undeletable
    assert_equal true, UndeletableBangModel.new.undeletable?
  end

  def test_undeletable_bang_models_to_param
    model = UndeletableBangModel.new
    model.save
    to_param = model.to_param

    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
  end

  def test_destroy_behavior_for_undeletable_bang_models
    model = UndeletableBangModel.new
    model.save!
    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
  end

  def test_destroy_behavior_for_featureful_undeletable_bang_models
    model = get_featureful_bang_model
    assert_equal 0, model.class.count
    model.save!
    assert_equal 1, model.class.count
    model.destroy
    fail "should raise ActiveRecord::ReadOnlyRecord"
  rescue ActiveRecord::ReadOnlyRecord
  end

  private
  def get_featureful_model
    FeaturefulModel.new(:name => "not empty")
  end

  def get_featureful_bang_model
    FeaturefulBangModel.new(:name => "not empty")
  end
end

# Helper classes

class ParentModel < ActiveRecord::Base
  has_many :undeletable_models
end

class UndeletableModel < ActiveRecord::Base
  belongs_to :parent_model
  undeletable
end

class FeaturefulModel < ActiveRecord::Base
  undeletable
  validates :name, :presence => true, :uniqueness => true
end

class PlainModel < ActiveRecord::Base
end

class CallbackModel < ActiveRecord::Base
  undeletable
  before_destroy {|model| model.instance_variable_set :@callback_called, true }
end

class ParentModel < ActiveRecord::Base
  undeletable
  has_many :related_models
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

class UndeletableBangModel < ActiveRecord::Base
  undeletable!
end

class FeaturefulBangModel < ActiveRecord::Base
  undeletable!
  validates :name, :presence => true, :uniqueness => true
end
