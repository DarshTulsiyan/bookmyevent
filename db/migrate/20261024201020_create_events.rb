class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :organizer, null: false, foreign_key: { to_table: :users }
      t.string :title
      t.text :description
      t.string :venue
      t.datetime :starts_at
      t.integer :total_capacity
      t.integer :status

      t.timestamps
    end
  end
end
