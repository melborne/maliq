require "maliq/version"

module Maliq
  %w(system_extensions converter).each { |lib| require_relative 'maliq/' + lib }
end
