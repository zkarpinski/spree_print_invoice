if @hide_prices
  @column_widths = { 0 => 100, 1 => 390, 2 => 50 } 
  @align = { 0 => :left, 1 => :left, 2 => :right, 3 => :right }
else
  @column_widths = { 0 => 100, 1 => 240, 2 => 70, 3 => 50, 4 => 70 } 
  @align = { 0 => :left, 1 => :left, 2 => :left, 3 => :right, 4 => :right, 5 => :right}
end

# Line Items
bounding_box [0,cursor], :width => 530, :height => 400 do
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

  #move_down 4

  bounding_box [0,cursor], :width => 530 do
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

  bounding_box [20,cursor  ], :width => 400 do
    render :partial => "bye" unless @hide_prices
  end

  render :partial => "totals" unless @hide_prices
  
  move_down 2

  stroke do
    line_width 0.5
    line bounds.top_left, bounds.top_right
    line bounds.top_left, bounds.bottom_left
    line bounds.top_right, bounds.bottom_right
    line bounds.bottom_left, bounds.bottom_right
  end

end
