require 'undeletable/version'

module Undeletable
  class << self
    attr_accessor :debug
    def configure(&blk); class_eval(&blk); end
  end

  def self.included(klazz)
    klazz.extend Query
  end

  module Query
    def undeletable? ; true ; end
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

  # I'm hoping this won't fail checks!
  #def destroyed?
  #end
  #alias :deleted? :destroyed?
end

Undeletable.configure do
  self.debug = false
end

class ActiveRecord::Base
  def self.undeletable(args = nil)
    class_attribute :raise_on_delete, instance_writer: true
    self.raise_on_delete = false
    alias :destroy! :destroy
    alias :delete!  :delete
    include Undeletable
  end

  def self.undeletable!(args = nil)
    class_attribute :raise_on_delete, instance_writer: true
    self.raise_on_delete = true
    alias :destroy! :destroy
    alias :delete!  :delete
    include Undeletable
  end

  def self.undeletable? ; false ; end
  def undeletable? ; self.class.undeletable? ; end
end
