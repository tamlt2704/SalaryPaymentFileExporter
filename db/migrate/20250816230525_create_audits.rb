class CreateAudits < ActiveRecord::Migration[8.0]
  def change
    create_table :audits do |t|
      t.string :filepath
      t.datetime :exported_at

      t.timestamps
    end
  end
end
