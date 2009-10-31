["/etc/ssh","/usr/local/etc/ssh","/etc","/usr/local/etc"].each { |dir|
    {"SSHDSAKey_key" => "ssh_host_dsa_key.pub",
            "SSHRSAKey_key" => "ssh_host_rsa_key.pub"}.each { |name,file|
        Facter.add(name ) do
            setcode do
                value = nil
                filepath = File.join(dir,file)
                if FileTest.file?(filepath)
                    regex1 = %r{^(\S+) (\S+) (\S+)$}
                    regex2 = %r{^(\S+) (\S+)(\s+)$}
                    begin
                        line = File.open(filepath).read.chomp
                        if (match = regex1.match(line)) or (match = regex2.match(line))
                            value = match[2]
                        end
                    rescue
                        value = nil
                    end
                end
                value
            end # end of proc
        end # end of add
    } # end of hash each
    {"SSHDSAKey_comment" => "ssh_host_dsa_key.pub",
            "SSHRSAKey_comment" => "ssh_host_rsa_key.pub"}.each { |name,file|
        Facter.add(name ) do
            setcode do
                value = nil
                filepath = File.join(dir,file)
                if FileTest.file?(filepath)
                    regex = %r{^(\S+) (\S+) (\S+)$}
                    begin
                        line = File.open(filepath).read.chomp
                        if match = regex.match(line)
                            value = match[3]
                        end
                    rescue
                        value = nil
                    end
                end
                value
            end # end of proc
        end # end of add
    } # end of hash each
} # end of dir each
