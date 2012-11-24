require "maliq/version"

module Maliq
  %w(system_extensions file_utils converter).each { |lib| require_relative 'maliq/' + lib }
end
