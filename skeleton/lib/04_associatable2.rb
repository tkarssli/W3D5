require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    options = assoc_options[through_name]
    source_options = options.model_class.assoc_options[source_name]
    self.define_method(name) do
      debugger
      primary_id = self.id
      source_options.model_class.where(source_options.foreign_key => primary_id)
    end
  end
end
