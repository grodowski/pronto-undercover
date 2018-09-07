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
      return [] unless @patches.first
      report = ::Undercover::Report.new(
        @patch_changeset, undercover_options
      ).build
      report.build_warnings.map(&method(:undercover_warning_to_message))
    rescue Errno::ENOENT => e
      warn("Could not open file! #{e}")
      []
    end

    private

    def undercover_warning_to_message(warning)
      msg = "#{warning.node.human_name} #{warning.node.name} needs a test!" \
        " (coverage: #{warning.coverage_f})"

      line = @patches.find_line(
        Pathname.new(File.expand_path(warning.file_path)),
        warning.first_line
      )
      Message.new(warning.file_path, line, DEFAULT_LEVEL, msg)
    end

    def undercover_options
      config = Pronto::ConfigFile.new.to_h
      opts = []
      opts << "-l#{config['lcov']}" if config['lcov']
      opts << "-r#{config['ruby-syntax']}" if config['ruby-syntax']
      opts << "-p#{config['path']}" if config['path']
      ::Undercover::Options.new.parse(opts)
    end
  end
end
