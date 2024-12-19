# frozen_string_literal: true

class DocumentDataDictionaryEntry < ApplicationRecord
  # Associations
  belongs_to :document_data_dictionary

  # Validations
  validates :friendlier_id, :field_name, :field_type, :values, presence: true
end
