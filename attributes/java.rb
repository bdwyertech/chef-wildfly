# encoding: UTF-8
# rubocop:disable LineLength
#
# => Java Configuration
    default['java']['install_flavor'] = 'oracle'
    default['java']['oracle']['accept_oracle_download_terms'] = true
    default['java']['jdk_version'] = '7'
    default['java']['jdk']['7']['x86_64']['url'] = 'http://download.oracle.com/otn-pub/java/jdk/7u55-b13/jdk-7u55-linux-x64.tar.gz'
    default['java']['jdk']['7']['x86_64']['checksum'] = '86f8c25718801672b7289544119e7909de82bb48393b78ae89656b2561675697'
