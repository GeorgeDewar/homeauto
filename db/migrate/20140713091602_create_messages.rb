class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message

      t.datetime :created_at
      t.datetime :sent_at
      t.datetime :acknowledged_at
    end
  end
end
