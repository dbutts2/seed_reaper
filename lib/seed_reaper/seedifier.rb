# frozen_string_literal: true

require 'active_support/inflector'
require_relative 'config_evaluator'
require_relative 'value_serializer'

module SeedReaper
  class Seedifier
    def initialize(config)
      @config = config
      @serialized = []
    end

    def seedify
      if base_config_evaluator.table_only
        seedify_table_only(@config.first[0])
      else
        seedify_collection(base_model, base_config)
      end
    end

    private

    def base_model
      return @config.to_s.camelize.constantize if @config.is_a?(Symbol)

      (base_config_evaluator.class_name || @config.first[0]).to_s.camelize.constantize
    end

    def base_config
      return nil if @config.is_a?(Symbol)

      @config.first[1]
    end

    def base_config_evaluator
      @base_config_evaluator ||= ConfigEvaluator.new(base_config)
    end

    def seedify_table_only(name)
      <<~UPSERT
        (
          Class.new(ActiveRecord::Base) do
            self.table_name = :#{name}
          end
        ).insert_all([
          #{
            [].tap do |attr_hashes|
              add_hash = ->(i) { attr_hashes << "{ #{serialize_insert_attrs(i)} }" }
              (
                Class.new(ActiveRecord::Base) do
                  self.table_name = name
                end
              ).tap do |c|
                c.primary_key ? c.find_each(&add_hash) : c.all.each(&add_hash)
              end
            end.join(",\n\s\s")
          }
        ])
      UPSERT
    end

    def seedify_collection(collection, config)
      ce = ConfigEvaluator.new(config)
      evaluated_collection(collection, ce).reduce('') do |str, instance|
        str +=
          seedify_associations(instance, ce.belongs_to_schema(instance)) +
          serialize(instance, ce) +
          seedify_associations(instance, ce.non_belongs_to_schema(instance))
      end
    end

    def seedify_associations(instance, config)
      return '' if config.nil?

      if config.is_a?(Symbol)
        instance.send(config).tap do |association|
          return '' if association.blank?

          association = [association] unless association.respond_to?(:each)
          return seedify_collection(association, nil)
        end
      elsif config.is_a?(Array)
        config.map do |sub_config|
          seedify_associations(instance, sub_config)
        end.join
      elsif config.is_a?(Hash)
        config.map do |(association_name, sub_config)|
          association = instance.send(association_name)
          next '' if association.blank?

          association = [association] unless association.respond_to?(:each)
          seedify_collection(association, sub_config)
        end.join
      else
        fail "Your input config contains a #{config.class_name}. You may only use symbols, arrays and hashes."
      end
    end

    def evaluated_collection(collection, config_evaluator)
      limited_collection(
        joined_collection(collection, config_evaluator.joins),
        config_evaluator.count
      )
    end

    def limited_collection(collection, count)
      return collection unless collection.respond_to?(:limit)
      return collection.limit(count) if count

      collection.all
    end

    def joined_collection(collection, joins)
      return collection unless collection.respond_to?(:joins)
      return collection.joins(joins) if joins

      collection
    end

    def serialize(instance, config_evaluator)
      seed = "#{instance.class}.new(\n#{serialize_attrs(instance, config_evaluator)}\n).save!(validate: false)\n\n"
      hashed_seed = Digest::SHA2.hexdigest(seed)
      return '' if @serialized.include?(hashed_seed)

      @serialized << hashed_seed
      seed
    end

    def serialize_attrs(instance, config_evaluator)
      instance.attributes.to_h.reduce('') do |attr_str, (k, v)|
        nullify = [config_evaluator.nullify].flatten.compact.map(&:to_s).include?(k.to_s)
        attr_str += "\s\s#{k}: #{ValueSerializer.new(v).serialized(nullify: nullify)},\n"
      end[0...-2]
    end

    def serialize_insert_attrs(instance)
      instance.attributes.to_h.map do |(k, v)|
        "#{k}: #{ValueSerializer.new(v).serialized}"
      end.join(', ')
    end
  end
end
