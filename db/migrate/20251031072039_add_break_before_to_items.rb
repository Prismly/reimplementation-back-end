class AddBreakBeforeToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :break_before, :boolean, default: false, null: false unless column_exists?(:items, :break_before)
  end
end
