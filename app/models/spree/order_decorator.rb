Spree::Order.class_eval do
  include HasBarcode

  has_barcode :barcode,
    :outputter => :prawn,
    :type => :code_39,
    :value => Proc.new { |p| p.number }

  def valid_payments
    payments.where{(state == "pending") | (state == "completed")}
  end

  def payment_summary
    paysum = ""

    if valid_payments.size > 0
      pa = []

      valid_payments.each do |p|
        pm = p.payment_method

        if pm and pm.name == "Credit Card"
           pa.push("#{p.source.cc_type.upcase} #{p.source.display_number}")
        elsif pm
          pa.push("#{pm.name.upcase} - #{pm.description}")
        else
          "DELETED"
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

    if valid_payments.size > 0
      pa = []

      valid_payments.each do |p|
        pm = p.payment_method

        if pm and pm.name == "Credit Card"
           pa.push("#{p.source.cc_type.upcase}")
        elsif pm
          pa.push("#{pm.name.upcase}")
        else
          "DELETED"
        end
      end

      paysum = pa.join(", ")
    else
      paysum = "N/A"
    end

    paysum

  end
end
