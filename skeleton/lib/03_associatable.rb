require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    s = name.to_s
    defaults = {
      foreign_key: "#{s}_id".to_sym,
      primary_key: :id,
      class_name: s.capitalize
    }

    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
    
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    n = name.to_s
    scn = self_class_name.to_s
    defaults = {
      foreign_key: "#{scn.downcase}_id".to_sym,
      primary_key: :id,
      class_name: n.singularize.capitalize
    }

    options = defaults.merge(options)

    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    assoc_options[name] = BelongsToOptions.new(name, options)
    options = assoc_options[name]
    self.define_method(name) do
      foreign_id = self.send(options.foreign_key)
      return nil unless foreign_id
      options.model_class.find(foreign_id)
    end

  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, self.to_s, options)
    self.define_method(name) do
      primary_id = self.id
      options.model_class.where(options.foreign_key => primary_id)
    end

  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @hash ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
