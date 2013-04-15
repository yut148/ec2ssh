require 'spec_helper'
require 'ec2ssh/ssh_config'

describe Ec2ssh::SshConfig do
  describe '#parse!' do
    context 'when no section exists' do
      let(:path) { path = tmp_dir.join('ssh_config') }
      subject    { described_class.new(path)         }

      before do
        path.open('w') {|f| f.write <<-END }
### EC2SSH BEGIN ###
# Generated by ec2ssh http://github.com/mirakui/ec2ssh
# DO NOT edit this block!
# Updated 2013-01-01T00:00:00+00:00
Host db-01.ap-northeast-1
  HostName ec2-1-1-1-1.ap-northeast-1.ec2.amazonaws.com

### EC2SSH END ###
END
        subject.parse!
      end

      it { expect(subject.sections.size).to be == 1 }
      it { expect(subject.sections['default']).to be_an_instance_of Ec2ssh::SshConfig::Section }
    end

    context 'when a section exists' do
      let(:path) { path = tmp_dir.join('ssh_config') }
      subject    { described_class.new(path)         }

      before do
        path = tmp_dir.join('ssh_config')
        path.open('w') {|f| f.write <<-END }
Host foo.bar.com
  HostName 1.2.3.4
### EC2SSH BEGIN ###
# Generated by ec2ssh http://github.com/mirakui/ec2ssh
# DO NOT edit this block!
# Updated 2013-01-01T00:00:00+00:00
# section: foo
Host db-01.ap-northeast-1
  HostName ec2-1-1-1-1.ap-northeast-1.ec2.amazonaws.com

### EC2SSH END ###
END
        subject.parse!
      end

      it { expect(subject.sections.size).to be == 2 }
      it { expect(subject.sections['foo']).to be_an_instance_of Ec2ssh::SshConfig::Section }    end

    context 'when multiple sections exist' do
      let(:path) { path = tmp_dir.join('ssh_config') }
      subject    { described_class.new(path)         }

      before do
        path = tmp_dir.join('ssh_config')
        path.open('w') {|f| f.write <<-END }
Host foo.bar.com
  HostName 1.2.3.4
### EC2SSH BEGIN ###
# Generated by ec2ssh http://github.com/mirakui/ec2ssh
# DO NOT edit this block!
# Updated 2013-01-01T00:00:00+00:00
# section: foo
Host db-01.ap-northeast-1
  HostName ec2-1-1-1-1.ap-northeast-1.ec2.amazonaws.com
# section: bar
Host db-02.ap-northeast-1
  HostName ec2-1-1-1-2.ap-northeast-1.ec2.amazonaws.com

### EC2SSH END ###
END
        subject.parse!
      end

      it { expect(subject.sections.size).to be == 3 }
      it { expect(subject.sections['foo']).to be_an_instance_of Ec2ssh::SshConfig::Section }
      it { expect(subject.sections['bar']).to be_an_instance_of Ec2ssh::SshConfig::Section }
    end
  end

  describe Ec2ssh::SshConfig::Section do
    describe '#append' do
      let(:section) { Ec2ssh::SshConfig::Section.new('test') }
      before { section.append('foo') }

      it { expect(section.text).to eq 'foo' }
    end

    describe '#replace' do
      let(:section) { Ec2ssh::SshConfig::Section.new('test', 'foo') }
      before { section.replace!('bar') }

      it { expect(section.text).to eq 'bar' }
    end

    describe '#to_s' do
      context 'when no text given' do
        let(:section) { Ec2ssh::SshConfig::Section.new('test') }

        it { expect(section.to_s).to eq '' }
      end

      context 'when empty text given' do
        let(:section) { Ec2ssh::SshConfig::Section.new('test', '') }

        it { expect(section.to_s).to eq '' }
      end

      context 'when some text given' do
        let(:section) { Ec2ssh::SshConfig::Section.new('test', 'foo') }

        it {
          expect(section.to_s).to eq <<EOS
# section: test
foo
EOS
        }
      end
    end
  end
end
