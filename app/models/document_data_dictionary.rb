# frozen_string_literal: true

require "csv"

class DocumentDataDictionary < ApplicationRecord
  include ActiveModel::Validations

  # Callbacks (keep at top)
  after_save :parse_csv_file

  # Associations
  has_one_attached :csv_file
  belongs_to :document, foreign_key: :friendlier_id, primary_key: :friendlier_id
  has_many :document_data_dictionary_entries, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :csv_file, attached: true, content_type: {in: "text/csv", message: "is not a CSV file"}

  validates_with DocumentDataDictionary::CsvHeaderValidator

  def parse_csv_file
    if csv_file.attached?
      csv_data = CSV.parse(csv_file.download, headers: true)
      csv_data.each do |row|
        self.document_data_dictionary_entries.create!(row.to_h)
      end
    end
  end
end

