Spree::Order.class_eval do
  include HasBarcode

  has_barcode :barcode,
    :outputter => :prawn,
    :type => :code_39,
    :value => Proc.new { |p| p.number }

  def valid_payments
    payments.where{((state == "checkout") | (state == "pending") | (state == "completed")) & (amount > 0.0)}.order("created_at desc")
  end

  def display_pay_state(p)
    if p[:balance_due]
      "Payment: Balance Due"
    elsif p[:template] == "quote"
      ""
    else
      "Payment: #{payment_state.titlecase}"
    end
  end

  def amount_still_owed(balance_due = false)
    t = total.to_f

    valid_payments.each do |p|

      pm = p.payment_method

      if balance_due and pm.name == "Credit Card" and p.state == "completed"
        t -= p.amount.to_f
      elsif not balance_due and p.state == "completed"
        t -= p.amount.to_f
      end
    end

    return t
  end

  def payment_summary(balance_due = false)
    paysum = ""

    if valid_payments.size > 0
      pa = []

      valid_payments.each do |p|
        p_text = ""

        pm = p.payment_method
        if pm and pm.name == "Credit Card" and p.source.try(:cc_type)
          p_text += "#{p.source.cc_type.upcase} ends in #{p.source.last_digits}"
        elsif pm
          p_text += "#{pm.name.upcase}"
        end

        if not balance_due or pm.name == "Credit Card"
          p_text += ": #{p.state == "completed" ? "PAID" : "DUE"}="
        else
          p_text += ": DUE="
        end
        p_text += "#{Spree::Money.new(p.amount)}"


        pa.push(p_text)
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

        if pm and pm.name == "Credit Card" and p.source.try(:cc_type)
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
