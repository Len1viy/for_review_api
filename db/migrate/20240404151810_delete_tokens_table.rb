# frozen_string_literal: true

class DeleteTokensTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :tokens
  end
end
