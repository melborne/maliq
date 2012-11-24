require "maliq/version"

module Maliq
  %w(system_extensions converter file_handler).each { |lib| require_relative 'maliq/' + lib }
end
