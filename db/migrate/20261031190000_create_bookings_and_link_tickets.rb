class CreateBookingsAndLinkTickets < ActiveRecord::Migration[8.1]
  def up
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :tickets, :booking, foreign_key: true

    execute <<~SQL
      INSERT INTO bookings (user_id, event_id, created_at, updated_at)
      SELECT tickets.user_id, ticket_tiers.event_id,
             MIN(tickets.created_at), MAX(tickets.updated_at)
      FROM tickets
      INNER JOIN ticket_tiers ON ticket_tiers.id = tickets.ticket_tier_id
      GROUP BY tickets.user_id, ticket_tiers.event_id
    SQL

    execute <<~SQL
      UPDATE tickets
      SET booking_id = bookings.id
      FROM bookings, ticket_tiers
      WHERE ticket_tiers.id = tickets.ticket_tier_id
        AND bookings.user_id = tickets.user_id
        AND bookings.event_id = ticket_tiers.event_id
    SQL

    change_column_null :tickets, :booking_id, false
    remove_index :tickets, column: [ :user_id, :ticket_tier_id ]
    remove_reference :tickets, :user, foreign_key: true
  end
end
