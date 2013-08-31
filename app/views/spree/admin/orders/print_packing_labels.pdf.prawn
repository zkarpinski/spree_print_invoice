
@order.shipments.each do |s|
  @shipment = s
  render partial: "spree/admin/orders/print"
  unless s.id == @order.shipments.last.id
    start_new_page
  end
end


