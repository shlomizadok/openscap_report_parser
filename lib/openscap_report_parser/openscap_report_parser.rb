require 'openscap'
require 'openscap/ds/arf'
require 'openscap/xccdf/testresult'
require 'openscap/xccdf/ruleresult'
require 'openscap/xccdf/rule'
require 'openscap/xccdf/benchmark'

module OpenscapReportParser
  class Parse
    def initialize(arf_data)
      OpenSCAP.oscap_init
      size = arf_data.size
      @arf =  OpenSCAP::DS::Arf.new(:content => arf_data, :path => 'arf.xml.bz2', :length => size)
      @results = @arf.test_result.rr
      sds = @arf.report_request
      bench_source = sds.select_checklist!
      @bench = OpenSCAP::Xccdf::Benchmark.new(bench_source)
      @items = @bench.items
    end

    def parsed_report
      parsed_data = {}
      parsed_data[:metrics] = metrics
      parsed_data[:logs] = logs
      parsed_data.to_json
    end


    private

    def logs
      logs = []
      @results.each do |rr_id, result|
        log = {}
        result_data = search_hash(@items, rr_id)
        log[:source] = rr_id
        log[:result] = result.result
        log[:title] = result_data.title
        log[:description] = result_data.description
        log[:rationale] = result_data.rationale
        logs << log
      end
      logs
    end

    def metrics
      passed = 0
      failed = 0
      othered = 0
      @results.each do |rr_id, result|
        case result.result
          when 'pass', 'fixed'
            passed = passed + 1
          when 'fail'
            failed = failed + 1
          when 'notapplicable', 'notselected'
            next
          else
            othered = othered + 1
        end
      end
      {:passed => passed, :failed => failed, :other => othered}
    end

    def search_hash(h, search)
      return h[search] if h.fetch(search, false)

      h.keys.each do |k|
        answer = search_hash(h[k], search) if h[k].is_a? Hash
        return answer if answer
      end
      false
    end
  end
end