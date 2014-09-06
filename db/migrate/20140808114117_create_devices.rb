class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :definition
      t.string :properties

      t.timestamps
    end
  end
end
