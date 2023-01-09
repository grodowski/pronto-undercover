# frozen_string_literal: true

RSpec.describe Pronto::Undercover do
  it 'has a version number' do
    expect(Pronto::UndercoverVersion::VERSION).not_to be nil
  end

  describe '#run' do
    let(:patches) { [] } # pronto-undercover uses own git wrapper for now
    let(:valid_config) do
      {
        'lcov' => 'coverage/lcov/fixtures.lcov',
        'path' => '.',
        'ruby-syntax' => 'ruby22'
      }
    end
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
        results = Pronto.run(:staged, 'test.git', nil)

        expect(results.size).to eq(3)
      end

      it 'reports severity, text, filename and line number' do
        results = Pronto.run(:staged, 'test.git', nil)

        msg = results.find { |r| r.msg =~ /instance method foo/ }
        expect(msg).to be_a(Pronto::Message)
        expect(msg.line).to be_a(Pronto::Git::Line)
        expect(msg.msg).to eq(
          'instance method foo missing tests for line 10 (coverage: 0.5)'
        )
        expect(msg.level).to eq(:warning)
        expect(msg.line.new_lineno).to eq(10)
        expect(msg.runner).to eq(Pronto::Undercover)
      end

      it 'passes options from .pronto.yml to Undercover::Report' do
        write_config(valid_config)

        expect(Undercover::Report)
          .to receive(:new).and_wrap_original do |m, changeset, opts|
          expect(opts.lcov).to eq('coverage/lcov/fixtures.lcov')
          expect(opts.path).to eq('.')
          expect(opts.syntax_version).to eq('ruby22')
          m.call(changeset, opts)
        end

        Pronto.run(:staged, 'test.git', nil)

        delete_config
      end

      it 'prints a warning message with no available lcov file' do
        write_config('lcov' => 'does_not_exist')

        errmsg = 'Could not open file! No such file or ' \
                 "directory @ rb_sysopen - does_not_exist\n"
        expect { Pronto.run(:staged, 'test.git', nil) }
          .to output(errmsg).to_stderr

        delete_config
      end

      it 'correctly reports on a patch inside of a changed file' do
        write_config(valid_config)

        results = Pronto.run(:unstaged, 'test.git', nil)

        msg = results.find { |res| res.path == 'patch.rb' }
        expect(msg).to be_a(Pronto::Message)
        expect(msg.line).to be_a(Pronto::Git::Line)
        expect(msg.msg).to eq(
          'instance method foo_child missing tests for line 15 (coverage: 0.0)'
        )
        expect(msg.level).to eq(:warning)
        expect(msg.line.new_lineno).to eq(15)
        expect(msg.line.position).to eq(5)

        delete_config
      end
    end
  end

  def write_config(yaml_config_hash)
    File.write('.pronto.yml', {'pronto-undercover' => yaml_config_hash}.to_yaml)
  end

  def delete_config
    FileUtils.rm('.pronto.yml')
  end
end
