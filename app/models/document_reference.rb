# frozen_string_literal: true

require "csv"

# DocumentReference
class DocumentReference < ApplicationRecord
  belongs_to :document, foreign_key: :friendlier_id, primary_key: :friendlier_id
  belongs_to :reference_type
  after_save :reindex_document

  # Validations
  validates :friendlier_id, :reference_type_id, :url, presence: true
  validates :url, uniqueness: {scope: [:friendlier_id, :reference_type_id]}

  def self.import(file)
    logger.debug("CSV Import")
    ::CSV.foreach(file.path, headers: true) do |row|
      logger.debug("CSV Row: #{row.to_hash}")
      converted_row = convert_import_row(row)
      document_reference = DocumentReference.find_or_initialize_by(
        friendlier_id: converted_row[0],
        reference_type_id: converted_row[1],
        url: converted_row[2]
      )

      document_reference.update!(
        friendlier_id: converted_row[0],
        reference_type_id: converted_row[1],
        url: converted_row[2],
        label: converted_row[3]
      )
    end
    true
  end

  def self.destroy_all(file)
    logger.debug("CSV Destroy")
    ::CSV.foreach(file.path, headers: true) do |row|
      logger.debug("CSV Row: #{row.to_hash}")
      converted_row = convert_import_row(row)
      if DocumentReference.destroy_by(
        friendlier_id: converted_row[0],
        reference_type_id: converted_row[1],
        url: converted_row[2]
      )
        logger.debug("Destroyed: #{row.to_hash}")
      else
        logger.debug("Not Destroyed: #{row.to_hash}")
      end
    end
    true
  end

  def to_csv
    attributes.values
  end

  def reindex_document
    document.save
  end

  def self.convert_import_row(row)
    reference_type = ReferenceType.find_by(name: row[1])
    raise "ReferenceType not found" unless reference_type

    [row[0], reference_type.id, row[2], row[3]]
  end
end
