# encoding: UTF-8
# => Java Configuration
    default['java']['install_flavor'] = 'oracle'    
    default['java']['oracle']['accept_oracle_download_terms'] = true
    default['java']['jdk_version'] = '7'
    default['java']['jdk']['7']['x86_64']['url'] = 'http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz'
    default['java']['jdk']['7']['x86_64']['checksum'] = '764f96c4b078b80adaa5983e75470ff2'
