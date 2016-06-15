class CreatePaymentReasons < ActiveRecord::Migration
  def change
    create_table :payment_reasons do |t|
      t.string :reason
      t.timestamps null: false
    end
    PaymentReason.new({reason: "Fee"}).save
  end
end
