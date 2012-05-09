class AddMailTitleTemplateToGlobalSetting < ActiveRecord::Migration
  def change
    add_column :global_settings,:mail_title_template,:string,:null=>false
  end
end
