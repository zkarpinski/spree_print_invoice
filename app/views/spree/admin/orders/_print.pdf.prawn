require 'prawn/layout'


font "Helvetica"
im = "#{Rails.root.to_s}/public/assets/#{Spree::PrintInvoice::Config[:print_invoice_logo_path]}"

image im , :at => [0,720], :scale => 0.7

fill_color "E99323"
if @hide_prices and not @quote
  text I18n.t(:packaging_slip), :align => :right, :style => :bold, :size => 18
elsif not @hide_prices and @quote
  text("QUOTE", align: :right, style: :bold, size: 18)
else
  text I18n.t(:customer_invoice), :align => :right, :style => :bold, :size => 18
end
fill_color "000000"

move_down 1 

font "Helvetica",  size: 10
if @quote
  text "Q#{@order.number}", :align => :right
else
  text "#{I18n.t(:order_number)}: #{@order.number}", :align => :right
end
move_down 1

if @shipment
  text "Shipment: #{@shipment.number}", :align => :right
else
  text "", :align => :right
end
move_down 1

if @order.try(:customer_email_id)
  text("Customer: #{@order.customer_email_id}", align: :right)
  move_down 1
end

font "Helvetica", size: 10
unless @order.captured_at == nil
  text "Date: #{@order.captured_at.strftime("%m/%d/%Y")}", :align => :right
end

render partial: "spree/admin/purchase_orders/prawn/company_info"

# Address Stuff

bill_address = @order.bill_address
ship_address = @shipment ? @shipment.address : @order.ship_address
anonymous = @order.email =~ /@example.net$/


bounding_box [0,590], width: 300 do
  text "BILL TO", style: :bold
  move_down 3
  horizontal_rule
  move_down 3
  text "#{bill_address.to_s.gsub(/<br\/>/,"\n")}\nPhone: #{bill_address.phone}"
  if @order.customer_purchase_order_number and not @order.customer_purchase_order_number.blank?
    move_down 1 
    text "Customer PO: #{@order.customer_purchase_order_number}"
  end
end


bounding_box [310,590], width: 230 do
  text "SHIP TO", style: :bold
  move_down 3
  horizontal_rule
  move_down 3
  text "#{ship_address.to_s.gsub(/<br\/>/,"\n")}\nPhone: #{ship_address.phone}"
end


move_down 15
horizontal_rule
move_down 15

current_cursor = cursor

bounding_box [0,current_cursor], width: 430 do

  unless @quote
    text("OUR TERMS: Net 30.  We also accept payment by credit card.", align: :left, style: :bold)
    move_down 5
  end

  unless @order.special_instructions.blank?
    text("Special Instructions: #{@order.special_instructions.gsub(/\n/, " ")}", align: :left)
    move_down 5
  end

  if params["balance_due"] == "true"
    text "Payment: BALANCE DUE"
  elsif not @quote
    text "Payment: #{@order.payment_state.upcase} (#{(@quote == true ? "" : @order.payment_summary)})"
  else
    text "QUOTE ONLY - NOT AN INVOICE"
  end

  text "Shipment: #{@shipment ? @shipment.shipping_method.try(:name) :  @order.shipping_method.try(:name)}#{@order.shipments.size > 1 ? "Shipments: #{@order.shipments.size}\n" : ""}"
end

bounding_box [440,current_cursor], width: 100 do
  font "Helvetica", size: 14
  text "THANK YOU!", :align => :right
  move_down 5

  if @order.admin_user
    text "- #{@order.admin_user.email.split("@").first.titleize}", :align => :right
  end
end

move_down 20



if @hide_prices
  @column_widths = { 0 => 100, 1 => 390, 2 => 50 } 
  @align = { 0 => :left, 1 => :left, 2 => :right, 3 => :right }
else
  @column_widths = { 0 => 90, 1 => 250, 2 => 75, 3 => 50, 4 => 75 } 
  @align = { 0 => :left, 1 => :left, 2 => :center, 3 => :center, 4 => :right }
end

bounding_box [0,cursor], :width => 538, :height => 400 do
  move_down 2
  header = [Prawn::Table::Cell.new( :text => "ID", :font_style => :bold)]
  header << Prawn::Table::Cell.new( :text => "Title", :font_style => :bold ) 
  header << Prawn::Table::Cell.new( :text => "Price", :font_style => :bold ) unless @hide_prices
  header << Prawn::Table::Cell.new( :text => "Qty", :font_style => :bold, :align => 1 )
  header << Prawn::Table::Cell.new( :text => "Total", :font_style => :bold ) unless @hide_prices
    
  table [header],
    :position => :left,
    :border_width => 0,
    :vertical_padding   => 4,
    :horizontal_padding => 6,
    :font_size => 10,
    :column_widths => @column_widths,
    :background_color => "d8d8d8",
    :align => @align

  move_down 2
  horizontal_rule


  bounding_box [0,cursor], :width => 538 do
    move_down 10
    content = []

    if @hide_prices and @order.shipments.size > 1 
      line_items = @shipment.split_shipment_line_items
    else
      line_items = @order.line_items
    end
 
    line_items.each do |item|
      product_name = item.variant.product.name.split(":").first

      if item.respond_to?(:returnable) and not item.returnable
        product_name = "(NON-RETURNABLE) #{product_name}"
      end

      if item.discount > 0.0
        product_name += " - #{sprintf("%0.1f", item.discount)}% off"
      end

      row = [item.variant.sku]
      row << product_name
      row << number_to_currency(item.price) unless @hide_prices
      row << item.quantity
      row << number_to_currency(item.price * item.quantity) unless @hide_prices
      content << row
    end


    table content,
      :position => :left,
      :border_width => 0,
      :vertical_padding   => 2,
      :horizontal_padding => 6,
      :font_size => 10,
      :column_widths => @column_widths ,
      :align => @align
  end

  font "Helvetica", :size => 9

  totals = []

  totals << [Prawn::Table::Cell.new( :text => t(:subtotal), :font_style => :bold), number_to_currency(@order.item_total)]

  @order.adjustments.where(eligible: true).each do |charge|
    totals << [Prawn::Table::Cell.new( :text => charge.label + ":", :font_style => :bold), number_to_currency(charge.amount)]
  end

  totals << [Prawn::Table::Cell.new( :text => t(:order_total), :font_style => :bold), number_to_currency(@order.total)]
  
  bounding_box [bounds.right - 260, bounds.bottom + (totals.length * 18)], :width => 250 do
    table totals,
      :position => :right,
      :border_width => 0,
      :vertical_padding   => 2,
      :horizontal_padding => 6,
      :font_size => 10,
      :column_widths => { 0 => 175, 1 => 75 } ,
      :align => { 0 => :right, 1 => :right }

  end

  font "Helvetica", size: 8
  additional_info = " - #{@order.completed_at.strftime("%m/%d/%Y %l:%M %p")}"

  unless @order.slug.blank?
    additional_info += " - #{@order.slug}"
  end

  bounding_box [10, 50], :width => 185, height: 40 do
    if @shipment
      text "S#{@order.id}#{additional_info}"
      barcode = Barby::Code39.new @shipment.number
      barcode.annotate_pdf(self, height: 30, width: 100)

    else
      text "O#{@order.id}#{additional_info}"
      barcode = Barby::Code39.new @order.number
      barcode.annotate_pdf(self, height: 30, width: 100)
    end

  end

  stroke do
    line_width 0.5
    line bounds.top_left, bounds.top_right
    line bounds.top_left, bounds.bottom_left
    line bounds.top_right, bounds.bottom_right
    line bounds.bottom_left, bounds.bottom_right
  end

end

move_down 10


