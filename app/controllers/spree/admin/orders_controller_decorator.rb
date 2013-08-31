Spree::Admin::OrdersController.class_eval do
  respond_to :pdf

  def show
    load_order
    respond_with(@order) do |format|
      format.pdf do
        template = params[:template] || "invoice"
        render :layout => false , :template => "spree/admin/orders/#{template}.pdf.prawn"
      end
    end
  end

  def print_packing_labels 
    load_order
    respond_with(@order) do |format|
      format.pdf do
        @hide_prices = params[:template] = "packaging_slip"
        render :layout => false , :template => "spree/admin/orders/shipments.pdf.prawn"
      end
    end
  end

end
