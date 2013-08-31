Spree::Shipment.class_eval do
  def split_shipment_line_items
    Spree::LineItem.find_by_sql(["select l.id, l.variant_id, l.order_id, l.price, l.created_at, l.updated_at, l.currency,
                                 count(i.id) as quantity
                                 from spree_line_items l, spree_shipments s, spree_inventory_units i 
                                 where l.variant_id = i.variant_id and i.order_id = l.order_id and 
                                 i.shipment_id = s.id and s.order_id = l.order_id and i.shipment_id = ? group by l.id", id])
  end
end
