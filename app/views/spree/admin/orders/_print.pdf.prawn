require 'prawn/layout'


font "Helvetica"
im = "#{Rails.root.to_s}/public/assets/#{Spree::PrintInvoice::Config[:print_invoice_logo_path]}"

image im , :at => [0,720] #, :scale => 0.35

fill_color "E99323"
if @hide_prices
  text I18n.t(:packaging_slip), :align => :right, :style => :bold, :size => 18
else
  text I18n.t(:customer_invoice), :align => :right, :style => :bold, :size => 18
end
fill_color "000000"

move_down 4

font "Helvetica",  size: 8,  :style => :bold
text "#{I18n.t(:order_number)}: #{@order.number}", :align => :right
move_down 2
if @shipment
  text "Shipment: #{@shipment.number}", :align => :right
else
  text "", :align => :right
end
move_down 2

font "Helvetica", size: 8
text "Date: #{@order.completed_at.strftime("%m/%d/%Y")}", :align => :right

font "Helvetica", size: 8
render partial: "spree/admin/purchase_orders/prawn/company_info"

render :partial => "address"

move_down 15

if @order.special_instructions
  text "Special Instructions: #{@order.special_instructions.gsub(/\n/, " ")}"
end

move_down 20

render :partial => "line_items_box"
move_down 10

if @shipment
  text "SHIPMENT"
  barcode = Barby::Code39.new @shipment.number
  barcode.annotate_pdf(self, height: 20, width: 100)

else
  text "ORDER"
  barcode = Barby::Code39.new @order.number
  barcode.annotate_pdf(self, height: 20, width: 100)
end
