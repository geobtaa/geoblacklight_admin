# frozen_string_literal: true

# ImportDocument class
class ImportDocument < ApplicationRecord
  has_many :import_document_transitions, autosave: false, dependent: :destroy

  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ImportDocumentTransition,
    initial_state: :queued
  ]

  def state_machine
    @state_machine ||= ImportDocumentStateMachine.new(self, transition_class: ImportDocumentTransition)
  end

  def to_hash
    data_hash = {
      friendlier_id: friendlier_id,
      title: title,
      json_attributes: nullify_empty_json_attributes,
      import_id: import_id
    }

    append_created_at(data_hash)
    append_updated_at(data_hash)
  end

  def nullify_empty_json_attributes
    clean_hash = {}

    json_attributes.each do |key, value|
      clean_hash[key] = value.present? ? value : nil
    end

    clean_hash
  end

  def append_created_at(data_hash)
    if data_hash.has_key?("date_created_dtsi")
      data_hash.merge!({created_at: data_hash["date_created_dtsi"]})
    end

    data_hash
  end

  def append_updated_at(data_hash)
    if data_hash.has_key?("date_modified_dtsi")
      data_hash.merge!({updated_at: data_hash["date_modified_dtsi"]})
    end
    
    data_hash
  end
end
