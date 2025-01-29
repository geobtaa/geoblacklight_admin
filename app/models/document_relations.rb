# frozen_string_literal: true

# DocumentRelations
class DocumentRelations
  # The initializer takes in the "Document" whose relations we need to fetch.
  def initialize(document)
    @document = document
    # We'll store the results in an instance var so we can memoize or
    # modify them within private methods before returning.
    @relations = {}
  end

  # Public method to fetch all relationships.
  # Optionally accepts a "field" to return only that field's relationships.
  def call(field = nil)
    build_empty_relations
    build_ancestor_relations
    build_descendant_relations

    # If a specific field is requested, filter @relations down
    if field.present?
      @relations.select { |k, _| k == field }
    else
      @relations
    end
  end

  private

  # For each relationship field, initialize a structure in @relations
  def build_empty_relations
    @document.relationship_fields.each do |relationship_field|
      @relations[relationship_field] ||= {ancestors: [], descendants: []}
    end
  end

  # Build the "ancestors" side of the relationships
  def build_ancestor_relations
    @document.relationship_fields.each do |relationship_field|
      # Decide if this field is an Array or not
      field_value = @document.send(relationship_field)
      if field_value.is_a?(Array)
        field_value.each do |f|
          @relations[relationship_field][:ancestors] << Document.where(
            "friendlier_id IN (?)", f
          )
        end
      else
        @relations[relationship_field][:ancestors] << Document.where(
          "friendlier_id IN (?)", field_value
        )
      end
    end
  end

  # Build the "descendants" side of the relationships
  def build_descendant_relations
    @document.relationship_fields.each do |relationship_field|
      @relations[relationship_field][:descendants] << Document.where(
        "(json_attributes->'#{relationship_field}')::jsonb @> ?",
        [@document.friendlier_id].to_json
      )
    end
  end
end
