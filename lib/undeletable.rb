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
    
    def delete(id_or_array)
      raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if self.raise_on_delete
      logger.debug("will not delete #{self}", e) if Undeletable.debug
    end
    
    def delete_all(conditions = nil)
      raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if self.raise_on_delete
      logger.debug("will not delete #{self}", e) if Undeletable.debug
    end
  end

  def force_destroy
    run_callbacks(:destroy) { force_delete }
  end

  def force_delete
    self.class.force_delete(send(self.class.primary_key))
  end

  def destroy
    raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if self.raise_on_delete
    logger.debug("will not delete #{self}", e) if Undeletable.debug
    run_callbacks(:destroy) { delete }
  end
  
  def delete
    raise ActiveRecord::ReadOnlyRecord.new("#{self} is undeletable") if self.raise_on_delete
    logger.debug("will not delete #{self}", e) if Undeletable.debug
  end

end

module UndeletableRails4Extensions
  extend ActiveSupport::Concern

  included do
    alias_method :force_destroy!, :destroy!
  end

  def destroy!
    raise ActiveRecord::RecordNotDestroyed.new("#{self} is undeletable")
  end
end

Undeletable.configure do
  self.debug = false
end

class ActiveRecord::Base

  def self.undeletable(args = nil)
    class_attribute :raise_on_delete, instance_writer: true
    class << self
      alias_method :force_delete, :delete
      alias_method :force_delete_all, :delete_all
    end
    include Undeletable
    include UndeletableRails4Extensions if defined?(ActiveRecord::VERSION::MAJOR) && ActiveRecord::VERSION::MAJOR > 3
  end

  def self.undeletable!(args = nil)
    class_attribute :raise_on_delete, instance_writer: true
    self.raise_on_delete = true
    class << self
      alias_method :force_delete, :delete
      alias_method :force_delete_all, :delete_all
    end
    include Undeletable
    include UndeletableRails4Extensions if defined?(ActiveRecord::VERSION::MAJOR) && ActiveRecord::VERSION::MAJOR > 3
  end

  def self.undeletable?
    false
  end

  def undeletable?
    self.class.undeletable?
  end
  
end
