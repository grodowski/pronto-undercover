# frozen_string_literal: true

module Pronto
  # Quacks like Undercover::Changeset but wraps Pronto::Patches
  # to provide full compatibility with pronto's git diff options
  class PatchChangeset
    T_ZERO = Time.strptime('0', '%s').freeze

    def initialize(patches)
      @patches = patches
    end

    def update
      self # no-op for this class
    end

    def last_modified
      mod = file_paths.map do |f|
        next T_ZERO unless File.exist?(f)

        File.mtime(f)
      end.max
      mod || T_ZERO
    end

    def file_paths
      @patches.map(&:new_file_full_path)
    end

    def each_changed_line
      @patches.each do |patch|
        patch.added_lines.each do |line|
          yield patch.delta.new_file[:path].to_s, line.new_lineno
        end
      end
    end

    def validate(lcov_report_path)
      return :no_changes if file_paths.empty?

      :stale_coverage if last_modified > File.mtime(lcov_report_path)
    end
  end
end
