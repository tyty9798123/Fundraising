class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.text :content, null: false
      t.string :image_url, null: false
      t.string :video_url, null: false
      t.integer :target_money, null: false
      t.belongs_to :users, null: false
      t.datetime :deadline, null: false
      t.timestamps
    end
  end
end
