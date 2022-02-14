# frozen_string_literal: true

require 'active_support/inflector'
require 'config_evaluator'

class Seedifier
  def initialize(config)
    @config = config
  end

  def seedify
    seedify_collection(base_model, base_config)
  end

  private

  def base_model
    return @config.to_s.camelize.constantize if @config.is_a?(Symbol)

    @config.first[0].to_s.camelize.constantize
  end

  def base_config
    return nil if @config.is_a?(Symbol)

    @config.first[1]
  end

  def seedify_collection(collection, config)
    ce = ConfigEvaluator.new(config)
    evaluated_collection(collection, ce).reduce('') do |str, instance|
      str += serialize(instance) + seedify_associations(instance, ce.schema)
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

  def serialize(instance)
    "#{instance.class}.new(\n#{serialize_attrs(instance)}\n).save!(validate: false)\n\n"
  end

  def serialize_attrs(instance)
    instance.attributes.to_h.reduce('') do |attr_str, (k, v)|
      attr_str += "\s\s#{k}: #{serialize_value(v)},\n"
    end[0...-2]
  end

  def serialize_value(value)
    if value.nil?
      "nil"
    elsif value.is_a?(Integer)
      value
    else
      "\"#{value}\""
    end
  end
end
