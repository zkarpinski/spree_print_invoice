@orders each do |o|
  @order = o
  render partial: "print"
  start_new_page(self) 
end
