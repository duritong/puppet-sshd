require 'etc'

# this fact will iterate over all the known users (as defined by the
# Etc module) and look in their .ssh directory for public keys. the
# public keys are exported in a user => [keys] hash, where keys are
# stored in the array without distinction of type
Facter.add(:ssh_keys_users) do
  setcode do
    keys_hash = {}
    Etc.passwd { |user|
      keys = {}
      Dir.glob(File.join(user.dir, '.ssh', '*.pub')).each { |filepath|
        if FileTest.file?(filepath)
          regex = %r{^ssh-(\S+) (\S+)\s?(.+)?$}
          begin
            line = File.open(filepath).read.chomp
            if (match = regex.match(line))
                keys[File.basename(filepath)] = {
                    'type' => match[1],
                    'key' => match[2],
                    'comment' => match[3]
                }
            end
          rescue
            puts "cannot read user SSH key: " + user.name
          end
        end
      }
      keys_hash[user.name] = keys if not keys.empty?
    }
    keys_hash
  end
end
