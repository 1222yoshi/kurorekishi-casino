class SorceryCore < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name,             null: false
      t.string :crypted_password
      t.string :salt
      t.integer :coin
      t.string :skill

      t.timestamps                null: false
    end
  end
end
