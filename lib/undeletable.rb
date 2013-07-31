require 'undeletable/version'

module Undeletable
  class << self
    attr_accessor :debug
    def configure(&blk)
      class_eval(&blk)
    end
  end

  extend ActiveSupport::Concern

  module ClassMethods
    def undeletable?
      true
    end

    def raise_on_delete?
      self.raise_on_delete
    end
    
    def delete(id_or_array)
      raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if raise_on_delete?
      logger.debug("will not #{self}.delete #{id_or_array.inspect}", e) if Undeletable.debug
    end
    
    def delete_all(conditions = nil)
      raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if raise_on_delete?
      logger.debug("will not #{self}.delete_all", e) if Undeletable.debug
    end
  end

  def destroy
    raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if raise_on_delete?
    logger.debug("will not delete #{self}", e) if Undeletable.debug
    run_callbacks(:destroy) { delete }
  end
  
  def delete
    raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if raise_on_delete?
    logger.debug("will not delete #{self}", e) if Undeletable.debug
  end

end

module UndeletableRails4Extensions
  extend ActiveSupport::Concern

  def destroy!
    raise ActiveRecord::RecordNotDestroyed.new("#{self} is undeletable")
  end
end

Undeletable.configure do
  self.debug = false
end

class ActiveRecord::Relation
  # don't use generic naming to try to avoid conflicts, since this isn't model class specific
  alias_method :undeletable_orig_relation_delete_all, :delete_all
  def delete_all(*args, &block)
    if klass.respond_to?(:undeletable?) && klass.undeletable?
      raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if klass.raise_on_delete?
      logger.debug("will not #{self}.delete_all", e) if Undeletable.debug
    else
      undeletable_orig_relation_delete_all(*args, &block)
    end
  end

  # don't use generic naming to try to avoid conflicts, since this isn't model class specific
  alias_method :undeletable_orig_relation_destroy_all, :destroy_all
  def destroy_all(*args, &block)
    if klass.respond_to?(:undeletable?) && klass.undeletable?
      raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if klass.raise_on_delete?
      logger.debug("will not #{self}.destroy_all", e) if Undeletable.debug
      if args.length > 0 && block_given?
        where(*args, &block).to_a.each {|object| object.run_callbacks(:destroy) { delete } }.tap { reset }
      elsif args.length > 0 && !block_given?
        where(*args).to_a.each {|object| object.run_callbacks(:destroy) { delete } }.tap { reset }
      elsif args.length == 0 && block_given?
        where(&block).to_a.each {|object| object.run_callbacks(:destroy) { delete } }.tap { reset }
      else
        to_a.each {|object| object.run_callbacks(:destroy) { delete } }.tap { reset }
      end
    else
      undeletable_orig_relation_destroy_all(*args, &block)
    end
  end
end

class ActiveRecord::Base

  def self.undeletable
    undeletable_init(false)
  end

  def self.undeletable!
    undeletable_init(true)
  end

  def self.undeletable?
    false
  end

  def undeletable?
    self.class.undeletable?
  end

  def self.raise_on_delete?
    false
  end

  def raise_on_delete?
    self.class.raise_on_delete?
  end  
  
private

  def self.undeletable_init(raise_on_delete_val)
    class_attribute :raise_on_delete, instance_writer: true
    self.raise_on_delete = raise_on_delete_val
    class << self
      alias_method :undeletable_orig_class_delete, :delete
      alias_method :undeletable_orig_class_delete_all, :delete_all
    end
    alias_method :undeletable_orig_delete, :delete
    alias_method :undeletable_orig_destroy, :destroy
    include Undeletable
    if defined?(ActiveRecord::VERSION::MAJOR) && ActiveRecord::VERSION::MAJOR > 3
      alias_method :undeletable_orig_destroy!, :destroy!
      include UndeletableRails4Extensions
    end
  end
end

