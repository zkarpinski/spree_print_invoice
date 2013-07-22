Spree::Order.class_eval do
  include HasBarcode

  has_barcode :barcode,
    :outputter => :prawn,
    :type => :code_39,
    :value => Proc.new { |p| p.number }
end
