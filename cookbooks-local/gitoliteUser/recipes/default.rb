# Create our gitolite user

gitolite_user 'git' do
  home    '/var/lib/git'
  version 'stable'
  ssh_key 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvLmZcu1LlXRYig6kAxgKjVayKVBU5Y/TuRbvGjglSXJAmaqrDiFd1yvXpy2I1iuflSgnVh86JlpDlkATVSYYBDv2NWeuCiOklQnbxx6Cgy0daHYJSWRjcYO6yokCMMgluEjXckB1zTV9XDpD0FoIJrqI5tu9utUofiYFOwO7Llri7hTsklnEaoy+q8Uk5TnKgvbjRAhKNmLmr/BgkvB/ZeBlXQu7ndbJWMEC7KfnTq7C3iyT1h/4QeIWDINHLa2tA3+UMbsDr4yDK6OdyHwh3UXq1uKpMNBBbHU+DhD7LrdvvsIrRZgZyaAAjsMBMhmxtY3du5y9JGoJ3ihKt6H/j vagrant@debian-70rc1-x64-vbox4210'
end

