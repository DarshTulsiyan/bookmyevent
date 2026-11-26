class AddPriceCentsToTicketTiers < ActiveRecord::Migration[8.1]
  def change
    add_column :ticket_tiers, :price_cents,
              :integer, null: false, default: 0

    add_check_constraint :ticket_tiers,
                        "price_cents >= 0",
                        name: "ticket_tiers_price_nonnegative"
  end
end
