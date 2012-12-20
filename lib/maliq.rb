require "maliq/version"

module Maliq
  %w(system_extensions file_utils converter builder).each { |lib| require_relative 'maliq/' + lib }
end
