class CreateTransferts < ActiveRecord::Migration
  def change
    create_table :transferts do |t|
      t.string :filename
      t.string :code
      t.string :name
      t.float :coord_x
      t.float	:coord_y
      t.decimal :baz_dot, precision: 17, scale: 2
      t.decimal :rev_dot, precision: 17, scale: 2
      t.timestamps null: false
    end
  end
end
