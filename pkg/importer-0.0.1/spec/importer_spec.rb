require File.dirname(__FILE__) + '/spec_helper.rb'
require 'importer/csv'

# Time to add your specs!
# http://rspec.info/
describe "Tests for the CVS importer" do

  after(:each) do
    File.delete @csv.errors_filename if File.exists?(@csv.errors_filename)
    File.delete @csv.exceptions_filename if File.exists?(@csv.exceptions_filename)
    File.delete @csv.ignores_filename if File.exists?(@csv.ignores_filename)
  end

  it "make sure it processes all rows" do
    count = 0
    @csv = Importer::CSV.open("files/test_import.csv") do
      count += 1
    end
    @csv.rows.should == count
    @csv.errors.should == 0
    @csv.ignores.should == 0
  end

  it "make sure logs all ignored rows" do
    @csv = Importer::CSV.open("files/test_import.csv") do
      Importer::CSV::IGNORE
    end
    @csv.ignores.should == @csv.rows
    @csv.errors.should == 0
    count_rows(@csv.ignores_filename).should == @csv.rows

  end

  it "make it logs all exceptions " do
    @csv = Importer::CSV.open("files/test_import.csv") do
      raise "goodbye cruel world"
    end
    @csv.ignores.should == 0
    @csv.errors.should == @csv.rows
    count_rows(@csv.errors_filename).should == @csv.rows

  end

def count_rows(file)
    count = 0
    Importer::CSV.open(file) do
      count += 1
    end
    count
  end
end