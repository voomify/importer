# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{importer}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Russell Edens"]
  s.date = %q{2010-01-23}
  s.description = %q{This is a general purpose importer gem.
This gem handles importing csv files. Usage:

Importer::CSV.open("somefile.csv") do |row, index|
    # process the row
    # if you want to ignore the row return Importer::CSV::IGNORE it will be
    # added to the ignore .csv file in the log directory
    # if you have an exception while processing a row it will be added to the
    # error .csv file in the log directory with the exception information in the error .log file
    # you can re-run these files if you need to
end}
  s.email = ["russell@voomify.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".idea/.rakeTasks", ".idea/encodings.xml", ".idea/importer.iml", ".idea/misc.xml", ".idea/modules.xml", ".idea/vcs.xml", ".idea/workspace.xml", "History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/importer.rb", "lib/importer/csv.rb", "script/console", "script/destroy", "script/generate", "spec/files/test_import.csv", "spec/importer_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake"]
  s.homepage = %q{http://github.com/#{github_username}/#{project_name}}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{voomify-importer}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{This is a general purpose importer gem}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faster_csv>, [">= 1.5.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.4.0"])
    else
      s.add_dependency(%q<faster_csv>, [">= 1.5.0"])
      s.add_dependency(%q<hoe>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<faster_csv>, [">= 1.5.0"])
    s.add_dependency(%q<hoe>, [">= 2.4.0"])
  end
end
