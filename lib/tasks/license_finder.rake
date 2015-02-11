desc 'Run license_finder'
task :license_finder do
  exit 1 unless system 'license_finder --quiet'
end
