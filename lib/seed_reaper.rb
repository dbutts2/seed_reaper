# frozen_string_literal: true

class SeedReaper
  def initialize(config)
    @config = config
  end

  def write!
    FileUtils.rm_rf('db/seeds/.', secure: true)

    @config.each_with_index do |element, i|
      File.open("db/seeds/#{i.to_s.rjust(@config.count.digits.count, '0')}_#{file_name(element)}.seeds.rb", 'w') do |file|
        file.write(Seedifier.new(element).seedify)
      end
    end
  end

  private

  def file_name(element)
    return element if element.is_a?(Symbol)

    element.first[0]
  end
end
