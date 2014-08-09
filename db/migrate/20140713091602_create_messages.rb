class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :device
      t.string :message

      t.timestamps
      t.datetime :sent_at
      t.datetime :acknowledged_at
    end
  end
end
