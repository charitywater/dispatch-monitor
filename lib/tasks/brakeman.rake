desc 'Run brakeman'
task :brakeman do
  exit 1 unless system 'brakeman -z'
end
