require 'zip' # gem install rubyzip
require 'optparse'
require 'ostruct'

module Zconv
  class App

    attr_accessor :options, :parser

    def initialize
      @options = OpenStruct.new(from_code: Encoding.default_external,
                               to_code: Encoding.default_external)

      @parser = OptionParser.new do |parser|
        parser.on('-f ENCODING', '--from-code=ENCODING', :REQUIRED,
                  'the encoding of the input') do |enc|
          options.from_code = Encoding.find(enc) if enc
        end

        parser.on('-tENCODING', '--to-code=ENCODING', :REQUIRED,
                  'the encoding of the output') do |enc|
          options.to_code = Encoding.find(enc) if enc
        end

        parser.on('-iINPUT', '--input-file=INPUT', :REQUIRED,
                  'the input zip file') do |file|
          options.input = file
        end

        parser.on('-oOUTPUT', '--output-file=OUTPUT', :REQUIRED,
                  'the output zip file') do |file|
          options.output = file
        end

        parser.on('-h', '--help', 'print this help message') do
          puts parser
          exit
        end
      end
    end

    def run
      ARGV << '--help' if ARGV.empty?
      @parser.parse!

      Zip::File.open(options.output, Zip::File::CREATE) do |out_zip|
        Zip::File.open(options.input) do |in_zip|
          in_zip.each do |in_entry|
            out_name = in_entry.name.encode(options.to_code, options.from_code)
            if in_entry.directory?
              out_zip.mkdir(out_name)
            else
              out_zip.get_output_stream(out_name) do |f|
                f.write(in_entry.get_input_stream.read)
              end
            end
          end
        end
      end
    end
  end
end
