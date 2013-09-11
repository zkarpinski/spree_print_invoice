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
                "PAYMENT: #{@order.payment_state.titlecase}" ]]
      data2 << [bill_address.company, ship_address.company,"SHIP: #{@shipment ? @shipment.shipping_method.try(:name) :  @order.shipping_method.try(:name)}"]

      data2 << [bill_address.address1, ship_address.address1, "#{@order.customer_purchase_order_number.blank? ? '' : 'PO: ' + @order.customer_purchase_order_number}"]

      data2 << [bill_address.address2, ship_address.address2,""] 

      data2 << ["#{bill_address.city},  #{(bill_address.state ? bill_address.state.abbr : "")} #{bill_address.zipcode}",
                "#{ship_address.city}, #{(ship_address.state ? ship_address.state.abbr : "")} #{ship_address.zipcode}", 
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
      :column_widths => { 0 => 300, 1 => 120, 2 => 120 }
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

