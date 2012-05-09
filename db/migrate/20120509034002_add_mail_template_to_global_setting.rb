class AddMailTemplateToGlobalSetting < ActiveRecord::Migration
  def change
    add_column :global_settings,:mail_template,:text,:null=>false
  end
end
