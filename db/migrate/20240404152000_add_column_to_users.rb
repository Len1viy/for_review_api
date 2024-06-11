# frozen_string_literal: true

class AddColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :validation_jwt, :string
  end
end
