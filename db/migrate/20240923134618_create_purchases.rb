class CreatePurchases < ActiveRecord::Migration[7.2]
  def change
    create_table :purchases do |t|
      t.references :user, foreign_key: true
      t.references :board, foreign_key: true
      
      t.timestamps
    end
  end
end
