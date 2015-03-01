require 'test/unit'

require_relative '../behaviors/describable'

class Desc
  include Describable
end

class DescribableTest < Test::Unit::TestCase
  def test_describable
    d = Desc.new
    assert_equal d.visible?, false
  end
  
end
