# lib/tasks/rotation.rake
desc 'rotation of playlist'
task :rotation => [:environment] do
  require 'rotation'
  include Rotation
  Rotation::rotate 3.months.ago
end
