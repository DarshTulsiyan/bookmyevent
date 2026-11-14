class AddDocumentReviewToEvents < ActiveRecord::Migration[8.1]
  def up
    add_column :events, :rejection_reason, :text

    remove_check_constraint :events, name: "events_status_valid"
    add_check_constraint :events, "status IN (0, 1, 2, 3)",
                         name: "events_status_valid"
    change_column_default :events, :status, from: 0, to: 3

    # Existing pending events predate document submission.
    execute "UPDATE events SET status = 3 WHERE status = 0"
  end

  def down
    execute "UPDATE events SET status = 0 WHERE status = 3"
    change_column_default :events, :status, from: 3, to: 0
    remove_check_constraint :events, name: "events_status_valid"
    add_check_constraint :events, "status IN (0, 1, 2)",
                         name: "events_status_valid"

    remove_column :events, :rejection_reason
  end
end