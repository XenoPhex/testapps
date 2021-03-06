#!/usr/bin/env bash

gcf login -a api.acceptance.cli.cf-app.com -u introspector -p introspector -o introspector -s introspector
cf target api.acceptance.cli.cf-app.com
cf login --username introspector --password introspector -o introspector -s introspector
gcf push pushed-with-gcf
cf push pushed-with-cf
curl pushed-with-gcf.acceptance.cli.cf-app.com > pushed-with-gcf.txt
curl pushed-with-cf.acceptance.cli.cf-app.com > pushed-with-cf.txt

/usr/bin/env ruby <<-EORUBY

size = eval(File.read('pushed-with-gcf.txt')).size
puts "Size of gcf push: #{size}\n"
size = eval(File.read('pushed-with-cf.txt')).size
puts "Size of cf push:  #{size}\n"
puts ""
gcf_diff = eval(File.read('pushed-with-gcf.txt')) - eval(File.read('pushed-with-cf.txt')).sort
cf_diff = eval(File.read('pushed-with-cf.txt')) - eval(File.read('pushed-with-gcf.txt')).sort
puts "Files present only in gcf push:"
gcf_diff.each { |f| puts "\t#{f.inspect}" }
puts ""
puts "Files present only in cf push:"
cf_diff.each { |f| puts "\t#{f.inspect}" }
puts ""

EORUBY

echo "For reference, here's the .cfignore:"
cat .cfignore

# Cleanup, comment-out to disable:
echo ""
rm pushed-with-gcf.txt
rm pushed-with-cf.txt
gcf delete pushed-with-gcf -f
gcf delete pushed-with-cf -f
gcf delete-route acceptance.cli.cf-app.com -n pushed-with-gcf -f
gcf delete-route acceptance.cli.cf-app.com -n pushed-with-cf -f
gcf logout
cf logout