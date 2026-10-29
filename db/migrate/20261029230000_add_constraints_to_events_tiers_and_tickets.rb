class AddConstraintsToEventsTiersAndTickets < ActiveRecord::Migration[8.1]
  def change
    # events
    change_column_null :events, :title, false
    change_column_null :events, :venue, false
    change_column_null :events, :starts_at, false
    change_column_null :events, :total_capacity, false
    change_column_default :events, :status, from: nil, to: 0
    change_column_null :events, :status, false

    add_check_constraint :events,
                         "total_capacity > 0",
                         name: "events_total_capacity_positive"

    add_check_constraint :events,
                         "status IN (0, 1, 2)",
                         name: "events_status_valid"

    # ticket_tiers
    change_column_null :ticket_tiers, :name, false
    change_column_null :ticket_tiers, :capacity, false
    change_column_default :ticket_tiers, :tickets_sold, from: nil, to: 0
    change_column_null :ticket_tiers, :tickets_sold, false

    add_index :ticket_tiers, [ :event_id, :name ], unique: true

    add_check_constraint :ticket_tiers,
                         "capacity > 0",
                         name: "ticket_tiers_capacity_positive"

    add_check_constraint :ticket_tiers,
                         "tickets_sold >= 0 AND tickets_sold <= capacity",
                         name: "ticket_tiers_tickets_sold_within_capacity"

    # tickets: one ticket per user per tier
    add_index :tickets, [ :user_id, :ticket_tier_id ], unique: true
  end
end
