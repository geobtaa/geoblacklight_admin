# frozen_string_literal: true

class ExportCsvDocumentLicensedAccessLinksService
  def self.short_name
    "Document Licensed Access Links"
  end

  def self.call(document_ids)
    Rails.logger.debug { "\n\nExportCsvDocumentLicensedAccessLinksService: #{document_ids.inspect}\n\n" }

    CSV.generate do |csv_file|
      csv_file << DocumentLicensedAccess.column_names
      DocumentLicensedAccess.where(document_id: document_ids).find_each do |access|
        csv_file << access.attributes.values
      end
    end
  end
end 