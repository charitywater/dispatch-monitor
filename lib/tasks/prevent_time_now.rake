desc 'Prefer Time.zone.now'
task :prevent_time_now do
  output = `cd #{Rails.root}; git grep 'Time\.now'`
  status = $?.to_i
  if status == 0
    puts "\e[31mYou should use Time.zone.now instead\e[0m"
    puts output
    exit 1
  end
end
