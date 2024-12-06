class CreateDocumentDataDictionaries < ActiveRecord::Migration[7.2]
  def change
    create_table :document_data_dictionaries do |t|
      t.string :friendlier_id
      t.string :label
      t.string :type
      t.string :values
      t.string :definition
      t.string :definition_source
      t.string :parent_friendlier_id
      t.integer :position
      
      t.timestamps
    end
  end
end
