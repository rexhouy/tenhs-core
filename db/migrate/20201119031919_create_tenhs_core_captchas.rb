class CreateTenhsCoreCaptchas < ActiveRecord::Migration[5.2]
  def change
    create_table :captchas do |t|
      t.string :mobile, null: false, limit: 11
      t.string :token, null: false, limit: 6
      t.datetime :sent_at, null: false
      t.timestamps
    end
  end
end
