Spree::LineItem.class_eval do

  def discount
    (1 - (price / variant.price)) * 100
  end
  
end
