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

  def index
    @orders = Spree::Order.where{(shipment_state == "ready") | (shipment_state == "partial")}
  end
end
