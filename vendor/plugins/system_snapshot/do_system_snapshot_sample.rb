
if File.exists?("vendor/plugins/system_snapshot/lib/system_snapshot.rb")
  require "vendor/plugins/system_snapshot/lib/system_snapshot"
else
  require 'lib/system_snapshot'
end


working_dir = ENV.key?("RAILS_ROOT") ? ENV["RAILS_ROOT"] : "."


processes_i_want_to_monitor = [
  "/usr/local/bin/ruby",
  "/usr/libexec/mysqld",
  "/usr/sbin/httpd"
]

system_snapshot(:processes => processes_i_want_to_monitor) \
  .append_to_csv_file("#{working_dir}/stats/#{Time.now.strftime("%Y%m%d")}#{`hostname`.strip}.csv")