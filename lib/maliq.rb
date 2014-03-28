module Maliq
  %w(version system_extensions file_utils converter create epub command).each do |lib|
    require_relative 'maliq/' + lib
  end
end
