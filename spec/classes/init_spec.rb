require 'spec_helper'

describe 'sshd' do


  shared_examples "a Linux OS" do
    it { should compile.with_all_deps }
    it { should contain_class('sshd') }
    it { should contain_class('sshd::client') }
  end

  context "Debian OS" do
    let :facts do
      {
        :operatingsystem => 'Debian',
        :osfamily        => 'Debian',
        :lsbdistcodename => 'wheezy',
      }
    end
    it_behaves_like "a Linux OS"
    it { should contain_package('lsb-release') }
  end

end