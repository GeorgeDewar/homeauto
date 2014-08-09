class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :expression
      t.references :device
      t.string :message

      t.timestamps
      t.datetime :last_run_at
    end
  end
end
