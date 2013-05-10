require 'spree_print_invoice/engine'
require 'prawn_handler'
require 'barby'
require 'has_barcode'

module Spree
  module PrintInvoice
    def self.config(&block)
      yield(Spree::PrintInvoice::Config)
    end
  end
end
