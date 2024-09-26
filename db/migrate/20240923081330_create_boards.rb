class CreateBoards < ActiveRecord::Migration[7.2]
  def change
    create_table :boards do |t|
      t.string :title
      t.string :body
      t.integer :price
      t.bigint :user_id

      t.timestamps
    end
  end
end
