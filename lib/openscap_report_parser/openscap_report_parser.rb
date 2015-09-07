require 'openscap'
require 'openscap/ds/arf'
require 'openscap/xccdf/testresult'
require 'openscap/xccdf/ruleresult'
require 'openscap/xccdf/rule'
require 'openscap/xccdf/benchmark'
require 'json'

module OpenscapReportParser
  class Parse
    def initialize(arf_data)
      OpenSCAP.oscap_init
      size         = arf_data.size
      @arf         = OpenSCAP::DS::Arf.new(:content => arf_data, :path => 'arf.xml.bz2', :length => size)
      @results     = @arf.test_result.rr
      sds          = @arf.report_request
      bench_source = sds.select_checklist!
      @bench       = OpenSCAP::Xccdf::Benchmark.new(bench_source)
      @items       = @bench.items
    end

    def as_json
      parse_report.to_json
    end

    def json_with_arf_html
      html = @arf.html.force_encoding('UTF-8')
      parse_report.merge!(:html => html).to_json
    end

    private

    def parse_report
      report        = {}
      report[:logs] = []
      passed        = 0
      failed        = 0
      other         = 0
      @results.each do |rr_id, result|
        # get rules and their results
        rule_data = search_hash(@items, rr_id)
        if result.result != 'notapplicable' && result.result != 'notselected'
          log = populate_result_data(rr_id, result.result, rule_data)
          report[:logs] << log
        end

        # create metrics for the results
        case result.result
        when 'pass', 'fixed'
          passed += 1
        when 'fail'
          failed += 1
        when 'notapplicable', 'notselected'
          next
        else
          other += 1
        end
      end
      report[:metrics] = { :passed => passed, :failed => failed, :other => other }
      report
    end

    def populate_result_data(result_id, rule_result, rule_data)
      log               = {}
      log[:source]      = result_id
      log[:result]      = rule_result
      log[:title]       = rule_data.title
      log[:description] = rule_data.description
      log[:rationale]   = rule_data.rationale
      log[:references]  = rule_data.references
      log
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
