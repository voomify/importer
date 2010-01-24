
require 'faster_csv'
require 'delegate'
require 'pathname'

# This is a general purpose class that will import a CSV file and write ignores and
# errors out. The ignores and errors are written out as .csv files that can be processed again.
# An exception log is also written out that has the exceptions along witht he row number for each exception
# As long as the input file is unique the errors, ignores and exception 
# files will be unique.
module Importer
  # This is a syntactic sugar method that allows you to access the row values using the
  # header text as the index   so instead of row[header["header name"]]  you can say row["header name"]  
  class Row < DelegateClass(Array)
    attr_accessor :row
    attr_accessor :header
    
    def initialize(row,header)
      @row = row
      @header = header
      super(@row)
    end

    # return the column in the row using the header name
    def [](header_name)
      @row[@header[header_name]]
    end    
  end
  
  class CSV

    IGNORE = 0

    attr_reader :file # the file to process
    attr_reader :options # options to process the file with
    attr_reader :header # header for the file. Filled in after the first row is read with open
    attr_reader :errors # number of errors
    attr_reader :ignores # number of ignores
    attr_reader :rows # current row number


    #  The is the default constructor
    #  usage is like File IO:
    # CSV.open('input_file') do |row|
    #     # do something with the row: row["header column"]
    #     # return IGNORE from your block to have the record added to the ignored
    #     # csv file. Throw and exception to have the record added to
    #     # the errors csv file and the exception log.
    # end
    #
    # To set the location of the ignore, errors and exception logs
    # set the :log_dir parameter in the options
    #
    def self.open(file, options={:log_dir=>'log'}, &block)
      csv = CSV.new(file, options)
      csv.process(&block)
      csv
    end

    def log_dir
      options[:log_dir]
    end

    def file_basename
      Pathname.new(file).basename
    end

    def errors_filename
      @error_file_name = build_filename(file_basename, "errors", "csv") unless @error_file_name
      @error_file_name
    end

    def exceptions_filename
      @exceptions_filename = build_filename(file_basename, "exceptions", "log") unless @exceptions_filename
      @exceptions_filename
    end

    def ignores_filename
      @ignores_filename = build_filename(file_basename, "ignore", "csv") unless @ignores_filename
      @ignores_filename
    end

    def process
      open(file).each_with_index do |line, row_index|
        FasterCSV.parse(line) do |row|
          if row_index == 0
            @header_row = row
            row.each_with_index do |item, column_index|
              @header[item.strip]=column_index if item
            end
          else
            begin
              @rows+= 1
              row_wrapper=Row.new(row, @header)
              if yield(row_wrapper, row_index)==0
                  write_ignored(row_wrapper, file)
              end
            rescue Exception=>e
              write_error(row_wrapper, e)
            end
          end
        end
      end
      p "Processed #{rows} with #{errors} Errors and #{ignores} Ignored records"
    end

    # writes an error row and exception log
    # this is called when the processing throws an exception
    def write_error (row, e)
      write_row(row,
                errors_filename,
                errors)
      write_exception(row, e)
    end

    # writes an ignored row to the given filename
    # this is called when the processing block returns IGNORED
    def write_exception (row, e)
      @errors += 1
      File.open(exceptions_filename, 'a')do |f|
        f.write("=======================================================================================\n")
        f.write("An error occured processing file '#{file}' on row: #{rows}\n")
        f.write("Error: #{e}\n")
        f.write("Stack: #{e.backtrace.join("\n")}\n")
      end
    end

    # writes an ignored row to the given filename
    # this is called when the processing block returns IGNORED
    def write_ignored (row, input_filename)
      write_row(row,
                ignores_filename,
                ignores)
      @ignores += 1          
    end

    private
#
    #
    # Use CVS.open instead of CVS.new
    #
    def initialize(file, options)
      @file = file
      @options = options
      @header = {}
      @date = nil
      @errors = 0
      @ignores = 0
      @rows = 0
    end

    # private helper for building an output filename  
    def build_filename(input_filename, type, ext)
      # make sure our log directory exists
      unless File.directory? log_dir
        Dir.mkdir log_dir
      end

      time = Time.now.strftime("%Y%m%d%H%M%S")
      "#{log_dir}/#{input_filename}-#{type}.#{time}.#{ext}"            
    end

    # private helper for writing a csv row to a file.
    def write_row (row, output_filename, has_written)
      FasterCSV.open(output_filename, "a") do |csv|
        csv << @header_row unless has_written > 0
        csv << row
      end
    end
  end
end
