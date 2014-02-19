# encoding: UTF-8
# => Wildfly User Configuration

# => By default, Wildfly expexts this password hash format:
# => # => username=HEX( MD5( username ':' realm ':' password))

# => Default user - wildfly - wildfly
default['wildfly']['users']['mgmt'] = [
  { id: 'wildfly', passhash: '2c6368f4996288fcc621c5355d3e39b7' }
]
