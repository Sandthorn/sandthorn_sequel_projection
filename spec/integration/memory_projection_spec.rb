require 'spec_helper'

require File.expand_path('../sandthorn_product',__FILE__)
require File.expand_path('../projection',__FILE__)
require File.expand_path('../projection_examples',__FILE__)

module SandthornSequelProjection
  RSpec.describe MyProjection do
    it_behaves_like "a projection"
  end
end