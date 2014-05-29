# encoding: UTF-8
# rubocop:disable LineLength
#
# => Java Configuration
    default['java']['install_flavor'] = 'oracle'
    default['java']['oracle']['accept_oracle_download_terms'] = true
    default['java']['jdk_version'] = '7'
    default['java']['jdk']['7']['x86_64']['url'] = 'http://download.oracle.com/otn-pub/java/jdk/7u60-b19/jdk-7u60-linux-x64.tar.gz'
    default['java']['jdk']['7']['x86_64']['checksum'] = 'c7232b717573b057dbe828d937ee406b7a75fbc6aba7f1de98a049cbd42c6ae8'
