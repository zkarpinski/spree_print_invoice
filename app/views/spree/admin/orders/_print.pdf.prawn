require 'prawn/layout'


font "Helvetica"
im = "#{Rails.root.to_s}/public/assets/#{Spree::PrintInvoice::Config[:print_invoice_logo_path]}"

image im , :at => [0,720], :scale => 0.7

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

# Address Stuff

bill_address = @order.bill_address
ship_address = @shipment ? @shipment.address : @order.ship_address
anonymous = @order.email =~ /@example.net$/


bounding_box [0,580], :width => 540 do
  move_down 2
  data = [[Prawn::Table::Cell.new( :text => I18n.t(:billing_address), :font_style => :bold ),
          Prawn::Table::Cell.new( :text => I18n.t(:shipping_address), :font_style => :bold ),
          Prawn::Table::Cell.new( :text => "Other Information", :font_style => :bold )]]

  table data,
    :position => :center,
    :border_width => 0.5,
    :vertical_padding   => 4,
    :horizontal_padding => 6,
    :font_size => 8,
    :border_style => :underline_header,
    :column_widths => { 0 => 200, 1 => 200, 2 => 130 }

  move_down 2
  horizontal_rule

  bounding_box [0,0], :width => 540 do
    move_down 2
    if anonymous and Spree::Config[:suppress_anonymous_address]
      data2 = [[" "," ", " "]] * 6 
    else
      data2 = [["#{bill_address.firstname} #{bill_address.lastname}", 
                "#{ship_address.firstname} #{ship_address.lastname}", 
                "PAYMENT: #{params[:balance_due] ? "BALANCE DUE" : @order.payment_state.titlecase}" ],
               [bill_address.address1, 
                ship_address.address1, 
                "SHIP: #{@shipment ? @shipment.shipping_method.try(:name) :  @order.shipping_method.try(:name)}"]
               ]

      data2 << [bill_address.address2, ship_address.address2, "#{@order.customer_purchase_order_number.blank? ? '' : 'PO: ' + @order.customer_purchase_order_number}"] unless 
                bill_address.address2.blank? and ship_address.address2.blank? and @order.customer_purchase_order_number.blank?

      data2 << ["#{bill_address.zipcode}, #{bill_address.city}  #{(bill_address.state ? bill_address.state.abbr : "")}",
                  "#{ship_address.zipcode}, #{ship_address.city} #{(ship_address.state ? ship_address.state.abbr : "")}", 
                  ""]
      data2 << [bill_address.country.name, ship_address.country.name, "#{@order.shipments.size > 1 ? "Shipments: #{@order.shipments.size}" : ""}"]
      data2 << ["Phone: #{bill_address.phone}", "Phone: #{ship_address.phone}", @order.payment_summary]
    end
    
    table data2,
      :position           => :center,
      :border => 0,
      :border_width => 0.0,
      :vertical_padding   => 1,
      :horizontal_padding => 6,
      :font_size => 8,
      :column_widths => { 0 => 200, 1 => 200, 2 => 130 }
  end

  move_down 2

  stroke do
    line_width 0.5
    line bounds.top_left, bounds.top_right
    line bounds.top_left, bounds.bottom_left
    line bounds.top_right, bounds.bottom_right
    line bounds.bottom_left, bounds.bottom_right
  end

end

move_down 10

if @order.special_instructions
  text "Special Instructions: #{@order.special_instructions.gsub(/\n/, " ")}"
  move_down 10
end


if @hide_prices
  @column_widths = { 0 => 100, 1 => 390, 2 => 50 } 
  @align = { 0 => :left, 1 => :left, 2 => :right, 3 => :right }
else
  @column_widths = { 0 => 100, 1 => 240, 2 => 70, 3 => 50, 4 => 70 } 
  @align = { 0 => :left, 1 => :left, 2 => :left, 3 => :right, 4 => :right, 5 => :right}
end

bounding_box [0,450], :width => 530, :height => 400 do
  #move_down 2
  header =  [Prawn::Table::Cell.new( :text => t(:sku), :font_style => :bold),
                Prawn::Table::Cell.new( :text => t(:item_description), :font_style => :bold ) ]
  header <<  Prawn::Table::Cell.new( :text => t(:price), :font_style => :bold ) unless @hide_prices
  header <<  Prawn::Table::Cell.new( :text => t(:qty), :font_style => :bold, :align => 1 )
  header <<  Prawn::Table::Cell.new( :text => t(:total), :font_style => :bold ) unless @hide_prices
    
  table [header],
    :position => :center,
    :border_width => 0,
    :vertical_padding   => 4,
    :horizontal_padding => 6,
    :font_size => 8,
    :column_widths => @column_widths ,
    :align => @align

  move_down 2
  horizontal_rule


  bounding_box [0,380], :width => 530 do
    #move_down 2
    content = []

    if @hide_prices and @order.shipments.size > 1 
      line_items = @shipment.split_shipment_line_items
    else
      line_items = @order.line_items
    end
 
    line_items.each do |item|
      row = [ item.variant.sku, item.variant.product.name]
      row << number_to_currency(item.price) unless @hide_prices
      row << item.quantity
      row << number_to_currency(item.price * item.quantity) unless @hide_prices
      content << row
    end


    table content,
      :position => :center,
      :border_width => 0,
      :vertical_padding   => 2,
      :horizontal_padding => 6,
      :font_size => 8,
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
  
  bounding_box [bounds.right - 360, bounds.bottom + (totals.length * 18)], :width => 300 do
    table totals,
      :position => :right,
      :border_width => 0,
      :vertical_padding   => 2,
      :horizontal_padding => 6,
      :font_size => 9,
      :column_widths => { 0 => 275, 1 => 75 } ,
      :align => { 0 => :right, 1 => :right }

  end

  bounding_box [10, 50], :width => 175, height: 40 do
    if @shipment
      text "S#{@order.id}"
      barcode = Barby::Code39.new @shipment.number
      barcode.annotate_pdf(self, height: 30, width: 100)

    else
      text "O#{@order.id}"
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


