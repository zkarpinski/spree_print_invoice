require 'spree_print_invoice/engine'
require 'prawn_handler'
require 'barby'
require 'barby/barcode/code_39'
require 'barby/outputter/png_outputter'
require 'tempfile'

module Spree
  module PrintInvoice
    def self.config(&block)
      yield(Spree::PrintInvoice::Config)
    end
  end
end
