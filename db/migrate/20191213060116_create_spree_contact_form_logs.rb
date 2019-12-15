class CreateSpreeContactFormLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :spree_contact_form_logs do |t|
      t.string :author_email
      t.string :author_name
      t.string :message
      t.string :user_agent
      t.string :ip
      t.string :referrer
      t.string :env
      t.boolean :flagged_as_spam
      t.timestamps
    end
  end
end
