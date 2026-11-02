class SetDefaultTicketsSoldOnTicketTiers < ActiveRecord::Migration[8.1]
  def change
    change_column_default :ticket_tiers, :tickets_sold, from: nil, to: 0
    change_column_null :ticket_tiers, :tickets_sold, false, 0
  end
end
