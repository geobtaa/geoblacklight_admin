# frozen_string_literal: true

# BulkActionsHelper
module BulkActionsHelper
  def bulk_actions_collection
    attrs = GeoblacklightAdmin::Schema.instance.importable_fields.collect { |key, _value| key }
    attrs.prepend("Publication State")
  end
end
