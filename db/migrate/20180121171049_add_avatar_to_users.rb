class AddAvatarToUsers < ActiveRecord::Migration[5.1]
  def change
    add_attachment :users, :avatar
  end
end
