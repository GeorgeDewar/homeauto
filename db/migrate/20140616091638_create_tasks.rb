class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.string :expression
      t.string :message

      t.datetime :last_run_at

      t.timestamps
    end
  end
end
