class AddTopicIdToAssignmentQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    # Change topic_id to bigint if it exists, else add it
    if column_exists?(:assignment_questionnaires, :topic_id)
      change_column :assignment_questionnaires, :topic_id, :bigint
    else
      add_column :assignment_questionnaires, :topic_id, :bigint
    end

    # Add index if missing
    add_index :assignment_questionnaires, :topic_id unless index_exists?(:assignment_questionnaires, :topic_id)

    # Add foreign key if missing
    add_foreign_key :assignment_questionnaires, :sign_up_topics, column: :topic_id unless foreign_key_exists?(:assignment_questionnaires, :sign_up_topics)
  end
end
