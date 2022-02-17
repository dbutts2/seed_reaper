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

    %i[count joins].each do |meta_field|
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
