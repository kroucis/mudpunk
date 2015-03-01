require 'test/unit'

require_relative '../behaviors/contains'

require_relative '../entities/entity'
require_relative '../entities/items/item'

class Container
  include Contains
end

class Carrier
  include Carries
end

class ContainsTest < Test::Unit::TestCase
  def test_add_entity
    container = Container.new
    ent = Entity.new
    assert_nil container.entities
    container.add_entity ent
    assert_not_nil container.entities
    assert_equal container.entities[0], ent
  end

  def test_remove_entity
    container = Container.new
    ent = Entity.new
    assert_nil container.entities
    container.add_entity ent

    assert_not_nil container.entities
    container.remove_entity ent
    assert_nil container.entities
  end

end # ContainsTest

class CarriesTest < Test::Unit::TestCase
  def test_add_entity
    carrier = Carrier.new
    carrier.max_weight = 10
    assert_equal carrier.max_weight, 10

    item = Item.new
    item.weight = 3
    assert_equal item.weight, 3

    result = carrier.add_entity item
    assert result
    assert_equal carrier.carried_weight, item.weight
    assert_not_nil carrier.entities

    item = Item.new
    item.weight = 8
    result = carrier.add_entity item
    assert_equal result, false
    assert_equal carrier.carried_weight, 3
  end

  def test_remove_entity
    carrier = Carrier.new
    carrier.max_weight = 10

    item = Item.new
    item.weight = 3
    carrier.add_entity item
    removed = carrier.remove_entity item
    assert removed
    assert_equal carrier.carried_weight, 0
  end

end # CarriesTest
