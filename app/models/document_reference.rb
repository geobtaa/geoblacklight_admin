# frozen_string_literal: true

require "csv"

# DocumentReference
#
# This class represents a reference to a document, which includes a URL and a reference type.
# It belongs to a document and a reference type, and it supports CSV import and export.
#
# Associations:
# - belongs_to :document
# - belongs_to :reference_type
#
# Callbacks:
# - after_save :reindex_document
#
# Validations:
# - Validates presence of :friendlier_id, :reference_type_id, :url
# - Validates uniqueness of :url scoped to :friendlier_id and :reference_type_id
#
# Scopes:
# - to_aardvark_references: Converts references to aardvark format
# - to_csv: Converts references to CSV format
class DocumentReference < ApplicationRecord
  belongs_to :document, foreign_key: :friendlier_id, primary_key: :friendlier_id
  belongs_to :reference_type
  after_save :reindex_document

  # Validations
  validates :friendlier_id, :reference_type_id, :url, presence: true
  validates :url, uniqueness: {scope: [:friendlier_id, :reference_type_id]}

  # Scopes
  scope :to_aardvark_references, -> {
    references = where(friendlier_id: pluck(:friendlier_id)).map(&:to_aardvark_reference)
    merged = {}
    references.each() do |ref|
      puts "Ref: #{ref.keys.first}"
      if ref.keys.first == "http://schema.org/downloadUrl"
        merged["http://schema.org/downloadUrl"] ||= []
        merged["http://schema.org/downloadUrl"] << {
          "url" => ref.values.first,
          "label" => ref[:label]
        }
      else
        merged[ref.keys.first] = ref.values.first
      end
    end
    merged
  }
  scope :to_csv, -> { where(friendlier_id: pluck(:friendlier_id)).map(&:to_csv) }

  # CSV Column Names
  #
  # Returns an array of column names for CSV export.
  #
  # @return [Array<String>] the CSV column names
  def self.csv_column_names
    ["friendlier_id", "reference_type", "reference_url", "label"]
  end

  # Import
  #
  # Imports document references from a CSV file.
  #
  # @param file [File] the CSV file to import
  # @return [Boolean] true if import is successful
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

  # Destroy All
  #
  # Destroys document references based on a CSV file.
  #
  # @param file [File] the CSV file to process
  # @return [Boolean] true if destroy is successful
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

  # To CSV
  #
  # Converts the document reference to an array suitable for CSV export.
  #
  # @return [Array<String>] the CSV row data
  def to_csv
    [
      friendlier_id,
      reference_type.name,
      url,
      label
    ]
  end

  # To Aardvark Reference
  #
  # Converts the document reference to an aardvark reference format.
  #
  # @return [Hash] the aardvark reference
  def to_aardvark_reference
    hash = {}
    hash[reference_type.reference_uri.to_s] = url
    hash[:label] = label if reference_type.reference_uri.to_s == "http://schema.org/downloadUrl"
    hash
  end

  # Reindex Document
  #
  # Reindexes the associated document.
  def reindex_document
    document.save
  end

  # Convert Import Row
  #
  # Converts a CSV row to an array of attributes for a document reference.
  #
  # @param row [CSV::Row] the CSV row to convert
  # @return [Array] the converted row data
  # @raise [RuntimeError] if the reference type is not found
  def self.convert_import_row(row)
    reference_type = ReferenceType.find_by(name: row[1])
    raise "ReferenceType not found" unless reference_type

    [row[0], reference_type.id, row[2], row[3]]
  end
end
