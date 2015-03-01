#
# entity.rb
# Copyright (c) 2012 Kyle Roucis. All rights reserved.
# Entity + Named + Describable
#

require_relative '../behaviors/named'
require_relative '../behaviors/locatable'
require_relative '../behaviors/describable'

require_relative '../mud/mud'

module MUD
  module Entities
    class Entity
      include Behaviors::Named
      include Behaviors::Describable
      include Behaviors::Locatable

      public
      def self.from_h itemdef
        instance = self.new
        instance.from_h itemdef
        instance
      end

      def self.build_entity name
        puts name
        data_path = "./data/#{name}.yaml"
        yaml_blob = YAML.load_file data_path
        yaml_blob = yaml_blob.symbolize_keys
        cls = yaml_blob[:class]
        klass = Kernel.const_get("MUD::Entities::#{cls}")
        ent = klass.from_h yaml_blob
      end

      def from_h itemdef
        self.name = itemdef[:name]
        snsinfo = Behaviors::Describable::SensoryInfo.new
        snsinfo.from_h itemdef[:descriptions]
        self.descriptions = snsinfo
        if zone_name = itemdef[:zone_name]
          self.zone = MUD.instance.get_zone zone_name
          self.room = self.zone[itemdef[:room_name].to_sym]
        end
      end

      def to_h
        result = 
        { 
          class: self.class.to_s, 
          name: self.name, 
          descriptions: self.descriptions.to_h,
        }

        if self.zone
          result[:zone_name] = self.zone.name
          result[:room_name] = self.room.filename || self.room.name
        end

        result
      end

    end # Entity

  end

end
