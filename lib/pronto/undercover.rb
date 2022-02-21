# frozen_string_literal: true

require 'pronto'
require 'undercover/options'
require 'undercover'
require 'pronto/patch_changeset'

module Pronto
  # Runner class for undercover
  class Undercover < Runner
    DEFAULT_LEVEL = :warning

    def initialize(patches, _commit = nil)
      super
      @patch_changeset = Pronto::PatchChangeset.new(patches)
    end

    # @return Array[Pronto::Message]
    def run
      return [] if !@patches || @patches.count.zero?

      @patches
        .select { |patch| valid_patch?(patch) }
        .map { |patch| patch_to_undercover_message(patch) }
        .flatten.compact
    rescue Errno::ENOENT => e
      warn("Could not open file! #{e}")
      []
    end

    private

    def valid_patch?(patch)
      patch.additions.positive? && ruby_file?(patch.new_file_full_path)
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def patch_to_undercover_message(patch)
      offending_line_numbers(patch).map do |warning, msg_line_no|
        patch
          .added_lines
          .select { |line| line.new_lineno == msg_line_no }
          .map do |line|
            # binding.pry
            next if warning.coverage_f >= min_coverage

            lines = untested_lines_for(warning)
            path = line.patch.delta.new_file[:path]
            msg = "#{warning.node.human_name} #{warning.node.name} missing tests" \
                  " for line#{'s' if lines.size > 1} #{lines.join(', ')}" \
                  " (coverage: #{warning.coverage_f})"
            Message.new(path, line, DEFAULT_LEVEL, msg, nil, self.class)
          end
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def undercover_warnings
      @undercover_warnings ||= ::Undercover::Report.new(
        @patch_changeset, undercover_options
      ).build.flagged_results
    end

    def offending_line_numbers(patch)
      patch_lines = patch.added_lines.map(&:new_lineno)
      path = patch.new_file_full_path.to_s
      undercover_warnings
        .select { |warning| File.expand_path(warning.file_path) == path }
        .map do |warning|
          first_line_no = patch_lines.find { |l| warning.uncovered?(l) }
          [warning, first_line_no] if first_line_no
        end.compact
    end

    def untested_lines_for(warning)
      warning.coverage.map do |ln, _cov|
        ln if warning.uncovered?(ln)
      end.compact
    end

    def undercover_options
      config = Pronto::ConfigFile.new.to_h['pronto-undercover']
      return ::Undercover::Options.new.parse([]) unless config

      opts = []
      opts << "-l#{config['lcov']}" if config['lcov']
      opts << "-r#{config['ruby-syntax']}" if config['ruby-syntax']
      opts << "-p#{config['path']}" if config['path']
      ::Undercover::Options.new.parse(opts)
    end

    def min_coverage
      @min_coverage ||= ENV['PRONTO_UNDERCOVER_MIN_COVERAGE'] ||
                        Pronto::ConfigFile.new.to_h.dig('pronto-undercover',
                                                        'min-coverage') ||
                        1
    end
  end
end
