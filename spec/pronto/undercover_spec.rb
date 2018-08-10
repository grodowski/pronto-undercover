# frozen_string_literal: true

RSpec.describe Pronto::Undercover do
  it 'has a version number' do
    expect(Pronto::UndercoverVersion::VERSION).not_to be nil
  end

  describe '#run' do
    let(:patches) { [] } # pronto-undercover uses own git wrapper for now
    subject { Pronto::Undercover.new(patches) }

    it 'returns no messages by default' do
      expect(subject.run).to be_empty
    end

    context 'with changes' do
      let(:test_repo_path) { File.expand_path('../fixtures', __dir__) }

      # pronto-undercover only runs in current workdir for now
      before { Dir.chdir(test_repo_path) }
      after { Dir.chdir(__dir__) }

      it 'reports undercover warnings as messages with' do
        results = Pronto.run(:staged, '.', nil)

        expect(results.size).to eq(2)
      end

      it 'reports severity, text, filename and line number' do
        results = Pronto.run(:staged, '.', nil)

        msg = results.first
        expect(msg).to be_a(Pronto::Message)
        expect(msg.line).to be_a(Pronto::Git::Line)
        expect(msg.msg).to eq('instance method foo needs a test! (coverage: 0.0)')
        expect(msg.level).to eq(:warning)
        expect(msg.line.new_lineno).to eq(8)
      end
    end
  end
end
