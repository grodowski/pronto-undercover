# frozen_string_literal: true

RSpec.describe Pronto::PatchChangeset do
  let(:staged_patches) do
    Pronto::Git::Repository.new('spec/fixtures/test.git').diff(:staged)
  end

  subject(:changeset) { described_class.new(staged_patches) }

  describe '#each_changed_line' do
    it 'consecutively yields changed filenames and lines' do
      collection = []
      changeset.each_changed_line { |file, ln| collection << [file, ln] }

      expect(collection).to include(*((1..19).map { |line| ['class.rb', line] }))
    end
  end

  describe '#update' do
    it 'does nothing and returns the changeset' do
      expect(subject.update).to eq(subject)
    end
  end

  describe '#last_modified' do
    it 'returns a date' do
      Timecop.freeze do
        FileUtils.touch(changeset.file_paths, mtime: Time.now)
        expect(changeset.last_modified).to eq(Time.now)
      end
    end
  end

  describe '#validate' do
    let(:lcov_path) { 'spec/fixtures/coverage/lcov/fixtures.lcov' }

    it 'returns :no_changes if patches is empty' do
      allow(changeset).to receive(:file_paths) { [] }
      expect(changeset.validate(lcov_path)).to eq(:no_changes)
    end

    it 'returns :stale_coverage if lcov mktime is older than last_modified' do
      FileUtils.touch(lcov_path, mtime: Pronto::PatchChangeset::T_ZERO)
      expect(changeset.validate(lcov_path)).to eq(:stale_coverage)
    end

    it 'returns nil otherwise' do
      FileUtils.touch(lcov_path, mtime: Time.now)
      expect(changeset.validate(lcov_path)).to eq(nil)
    end
  end
end
