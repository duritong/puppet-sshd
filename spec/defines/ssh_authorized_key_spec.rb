require 'spec_helper'

describe 'sshd::ssh_authorized_key' do

  context 'manage authorized key' do
    let(:title) { 'foo' }
    let(:ssh_key) { 'some_secret_ssh_key' }

    let(:params) {{
        :key => ssh_key,
    }}

    it { should contain_ssh_authorized_key('foo').with({
        'ensure' => 'present',
        'type'   => 'ssh-dss',
        'user'   => 'foo',
        'target' => '/home/foo/.ssh/authorized_keys',
        'key'    => ssh_key,
      })
    }
  end
end
