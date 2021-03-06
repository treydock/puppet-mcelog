require 'spec_helper'

describe 'mcelog', :type => :class do

  context 'osfamily RedHat' do
    let(:facts) {{
      :architecture => 'x86_64',
      :osfamily     => 'RedHat',
    }}

    context 'EL5.x' do
      before { facts[:operatingsystemmajrelease] = '5' }

      it { should contain_package('mcelog').with_ensure('present') }
      it do
        should contain_file('mcelog.conf').with({
          :ensure  => 'file',
          :path    => '/etc/mcelog.conf',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :content => /^daemon = yes$/,
        })
      end
      it { should_not contain_service('mcelog') }
    end # EL5.x

    context 'EL6.x' do
      before { facts[:operatingsystemmajrelease] = '6' }

      it { should contain_package('mcelog').with_ensure('present') }
      it do
        should contain_file('mcelog.conf').with({
          :ensure  => 'file',
          :path    => '/etc/mcelog/mcelog.conf',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :content => /^daemon = yes$/,
        })
      end
      it do
        should contain_service('mcelog').with({
          :ensure     => 'running',
          :name       => 'mcelogd',
          :hasstatus  => true,
          :hasrestart => true,
          :enable     => true,
        })
      end

      context 'config_file_template =>' do
        context 'mcelog/mcelog.conf.erb' do
          let(:params) {{ :config_file_template => 'mcelog/mcelog.conf.erb' }}

          it do
            should contain_file('mcelog.conf').with({
              :ensure  => 'file',
              :path    => '/etc/mcelog/mcelog.conf',
              :owner   => 'root',
              :group   => 'root',
              :mode    => '0644',
              :content => /^daemon = yes$/,
            })
          end
        end # mcelog/mcelog.conf.erb

        context 'dne/dne.erb' do
          let(:params) {{ :config_file_template => 'dne/dne.erb' }}

          it 'should fail' do
            expect { should contain_class('mcelog::params') }.
              to raise_error(Puppet::Error, /Could not find template 'dne\/dne.erb'/)
          end
        end # dne/dne.erb

        context '[]' do
          let(:params) {{ :config_file_template => [] }}

          it 'should fail' do
            expect { should contain_class('mcelog::params') }.
              to raise_error(Puppet::Error, /is not a string/)
          end
        end # []
      end # config_file_template =>

      context 'ensure => absent' do
        let(:params) {{ :ensure => 'absent' }}

        it { should contain_package('mcelog').with_ensure('absent') }
        it { should contain_file('mcelog.conf').with_ensure('absent') }
        it do
          should contain_service('mcelog').with({
            :ensure => 'stopped',
            :enable => 'false',
          })
        end
      end # ensure =>
    end # EL6.x

    context 'EL7.x' do
      before { facts[:operatingsystemmajrelease] = '7' }

      it { should contain_package('mcelog').with_ensure('present') }
      it do
        should contain_file('mcelog.conf').with({
          :ensure  => 'file',
          :path    => '/etc/mcelog/mcelog.conf',
          :owner   => 'root',
          :group   => 'root',
          :mode    => '0644',
          :content => /^daemon = yes$/,
        })
      end
      it do
        should contain_service('mcelog').with({
          :ensure     => 'running',
          :name       => 'mcelogd',
          :hasstatus  => true,
          :hasrestart => true,
          :enable     => true,
        })
      end
    end # EL7.x

    context 'unsupport operatingsystemmajrelease' do
      before { facts[:operatingsystemmajrelease] = '4' }

      it 'should fail' do
        expect { should contain_class('mcelog::params') }.
          to raise_error(Puppet::Error, /not supported on operatingsystemmajrelease: 4/)
      end
    end # EL4.x
  end # osfamily RedHat

  context 'unsupported architecture' do
    let :facts do
      {
        :architecture => 'i386',
        :osfamily     => 'RedHat',
      }
    end

    it 'should fail' do
      expect { should contain_class('mcelog::params') }.
        to raise_error(Puppet::Error, /not supported on architecture: i386/)
    end
  end # unsupported architecture

  context 'unsupported osfamily' do
    let :facts do
      {
        :architecture => 'x86_64',
        :osfamily     => 'Solaris',
      }
    end

    it 'should fail' do
      expect { should contain_class('mcelog::params') }.
        to raise_error(Puppet::Error, /not supported on osfamily: Solaris/)
    end
  end # unsupported osfamily
end
