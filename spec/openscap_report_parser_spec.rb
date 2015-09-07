require 'spec_helper'
describe OpenscapReportParser do
  it 'has a version number' do
    expect(OpenscapReportParser::VERSION).not_to be nil
  end

  it 'loads arf report without error' do
    file_path = Dir.pwd + '/spec/data/report_example'
    file = File.open(file_path, 'rb').read
    parser = OpenscapReportParser::Parse.new(file)
    expect { parser }.to_not raise_error(OpenSCAP::OpenSCAPError)
  end

  it 'errors if arf report is not bunzipped' do
    pending('Figure which error is raised on bunzipped file')
    file_path = Dir.pwd + '/spec/data/bunzipped_example'
    file = File.open(file_path, 'rb').read
    parser = OpenscapReportParser::Parse.new(file)
    expect { parser }.to raise_error(OpenSCAP::OpenSCAPError)
  end

  context 'as_json' do
    it 'returns the arf report as json' do
      file_path = Dir.pwd + '/spec/data/report_example'
      file = File.open(file_path, 'rb').read
      parser = OpenscapReportParser::Parse.new(file)
      json = JSON.parse(parser.as_json)
      expect(json).to include('logs')
      expect(json['metrics']).to eq('passed' => 34, 'failed' => 33, 'other' => 1)
    end

    it 'should include html code' do
      file_path = Dir.pwd + '/spec/data/report_example'
      file = File.open(file_path, 'rb').read
      parser = OpenscapReportParser::Parse.new(file)
      json = JSON.parse(parser.json_with_arf_html)
      expect(json).to include('logs')
      expect(json['html']).to include "<!DOCTYPE html>"
      expect(json['html']).to include "</html>"
    end
  end
end
