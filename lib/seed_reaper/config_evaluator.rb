# frozen_string_literal: true

module SeedReaper
  class ConfigEvaluator
    def initialize(config)
      @config = config
    end

    def schema
      return nil unless @config
      return @config.reject { |k| k == :meta } if @config.is_a?(Hash)
      return @config.reject { |c| c.is_a?(Hash) && c.has_key?(:meta) } if @config.is_a?(Array)

      @config
    end

    def belongs_to_schema(instance)
      return nil unless schema
      return schema.select { |k| instance._reflections[k.to_s].belongs_to? } if schema.is_a?(Hash)
      return schema.select do |c|
        if c.is_a?(Hash)
          instance._reflections[c.first[0].to_s].belongs_to?
        else
          instance._reflections[c.to_s].belongs_to?
        end
      end if schema.is_a?(Array)
      return schema if instance._reflections[schema.to_s].belongs_to?
    end

    def non_belongs_to_schema(instance)
      return nil unless schema
      return schema.reject { |k| instance._reflections[k.to_s].belongs_to? } if schema.is_a?(Hash)
      return schema.reject do |c|
        if c.is_a?(Hash)
          instance._reflections[c.first[0].to_s].belongs_to?
        else
          instance._reflections[c.to_s].belongs_to?
        end
      end if schema.is_a?(Array)
      return schema unless instance._reflections[schema.to_s].belongs_to?
    end

    %i[count joins nullify class_name].each do |meta_field|
      define_method meta_field do
        meta(meta_field)
      end
    end

    private

    def meta(field)
      return nil unless @config
      return @config.dig(:meta, field) if @config.is_a?(Hash)
      return nil unless @config.is_a?(Array)

      @config.select do |c|
        c.is_a?(Hash) && c.has_key?(:meta)
      end.first&.dig(:meta, field)
    end
  end
end
