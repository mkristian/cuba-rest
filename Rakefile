# -*- mode: ruby -*-
require 'cutest'

task :default => [ :example, :spec ]

task :spec do
  Dir['spec/*_spec.rb'].each { |f| require File.expand_path( f ) }
end

task :example do
  $LOAD_PATH << File.expand_path( 'lib' )
  Cutest.run Dir[ 'example/test/*/*_test.rb' ]
end

task :headers do
  require 'copyright_header'

  s = Gem::Specification.load( Dir["*gemspec"].first )

  args = {
    :license => s.license, 
    :copyright_software => s.name,
    :copyright_software_description => s.description,
    :copyright_holders => s.authors,
    :copyright_years => [Time.now.year],
    :add_path => 'lib',
    :output_dir => './'
  }

  command_line = CopyrightHeader::CommandLine.new( args )
  command_line.execute
end
# vim: syntax=Ruby
