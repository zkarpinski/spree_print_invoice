# Address Stuff

bill_address = @order.bill_address
ship_address = @order.ship_address
anonymous = @order.email =~ /@example.net$/


bounding_box [0,580], :width => 540 do
  move_down 2
  data = [[Prawn::Table::Cell.new( :text => I18n.t(:billing_address), :font_style => :bold ),
          Prawn::Table::Cell.new( :text =>I18n.t(:shipping_address), :font_style => :bold ),
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
                "PAYMENT: #{@order.payment_state.titlecase}" ],
               [bill_address.address1, 
                ship_address.address1, 
                "SHIP: #{@order.shipping_method.try(:name)}"]
               ]

      data2 << [bill_address.address2, ship_address.address2, "PO: #{@order.customer_purchase_order_number ? @order.customer_purchase_order_number : 'N/A' }"] unless 
                bill_address.address2.blank? and ship_address.address2.blank? and @order.customer_purchase_order_number.blank?

      data2 << ["#{@order.bill_address.zipcode}, #{@order.bill_address.city}  #{(@order.bill_address.state ? @order.bill_address.state.abbr : "")}",
                  "#{@order.ship_address.zipcode}, #{@order.ship_address.city} #{(@order.ship_address.state ? @order.ship_address.state.abbr : "")}", 
                  ""]
      data2 << [bill_address.country.name, ship_address.country.name, ""]
      data2 << ["Phone: #{bill_address.phone}", "Phone: #{ship_address.phone}", ""]
    end
    
    table data2,
      :position           => :center,
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

