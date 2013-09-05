Spree::Order.class_eval do
  include HasBarcode

  has_barcode :barcode,
    :outputter => :prawn,
    :type => :code_39,
    :value => Proc.new { |p| p.number }

  def payment_summary
    paysum = ""
    if payments
      pa = []
      payments.each do |p|
        if p.source_type == "Spree::CreditCard"
           pa.push("#{p.source.cc_type.upcase} #{p.source.display_number}")
        else
          pa.push("#{p.name.upcase} - #{p.description}")
        end
      end

      paysum = pa.join(", ")
    else
      paysum = "N/A"
    end

    paysum
  end
end
