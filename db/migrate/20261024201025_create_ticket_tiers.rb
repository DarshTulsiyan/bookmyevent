class CreateTicketTiers < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_tiers do |t|
      t.references :event, null: false, foreign_key: true
      t.string :name
      t.integer :capacity
      t.integer :tickets_sold

      t.timestamps
    end
  end
end
