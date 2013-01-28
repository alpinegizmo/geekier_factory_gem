require 'geekier_factory/api'
require 'geekier_factory/action'

module GeekierFactory
  def self.factorize(filename_with_path)
    description = File.read(filename_with_path)
    structure = YAML.load(description)
    API.new(structure)
  end
end