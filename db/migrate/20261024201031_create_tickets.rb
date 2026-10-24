class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ticket_tier, null: false, foreign_key: true
      t.datetime :checked_in_at

      t.timestamps
    end
  end
end
