# frozen_string_literal: true

require "csv"

# DocumentReference
class DocumentReference < ApplicationRecord
  belongs_to :document, foreign_key: :friendlier_id, primary_key: :friendlier_id
  belongs_to :reference
  after_save :reindex_document

  # Validations
  validates :friendlier_id, :reference_id, presence: true
  validates :url, presence: true

  def self.import(file)
    logger.debug("CSV Import")
    ::CSV.foreach(file.path, headers: true) do |row|
      logger.debug("CSV Row: #{row.to_hash}")
      document_reference = DocumentReference.find_or_initialize_by(friendlier_id: row[0], reference_id: row[1])
      document_reference.update!(row.to_hash)
    end
    true
  end

  def self.destroy_all(file)
    logger.debug("CSV Destroy")
    ::CSV.foreach(file.path, headers: true) do |row|
      logger.debug("CSV Row: #{row.to_hash}")
      DocumentReference.destroy_by(id: row[0], friendlier_id: row[1])
    end
    true
  end

  def to_csv
    attributes.values
  end

  def reindex_document
    document.save
  end
end
