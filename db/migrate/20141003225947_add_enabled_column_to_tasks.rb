class AddEnabledColumnToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :enabled, :boolean, default: true
    execute "update tasks set enabled = '1'"
  end
end
