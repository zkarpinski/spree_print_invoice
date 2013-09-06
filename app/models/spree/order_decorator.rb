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
        pm = p.payment_method
        if pm.type == "Credit Card"
           pa.push("#{p.source.cc_type.upcase} #{p.source.display_number}")
        else
          pa.push("#{pm.name.upcase} - #{pm.description}")
        end
      end

      paysum = pa.join(", ")
    else
      paysum = "N/A"
    end

    paysum
  end

  def short_payment_summary
    paysum = ""
    if payments
      pa = []
      payments.each do |p|
        pm = p.payment_method
        if pm.name == "Credit Card"
           pa.push("#{p.source.cc_type.upcase}")
        else
          pa.push("#{pm.name.upcase}")
        end
      end

      paysum = pa.join(", ")
    else
      paysum = "N/A"
    end

    paysum

  end
end
