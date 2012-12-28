module Maliq
  %w(version system_extensions file_utils converter create epub).each do |lib|
    require_relative 'maliq/' + lib
  end
end
