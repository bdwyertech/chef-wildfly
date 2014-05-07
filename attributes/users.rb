# encoding: UTF-8
# => Wildfly User Configuration

# => Access Control Provider (simple, or rbac)
default['wildfly']['acp'] = 'simple'

# => By default, Wildfly expexts this password hash format:
# => # => username=HEX( MD5( username ':' realm ':' password))

# => Default user - wildfly - wildfly
default['wildfly']['users']['mgmt'] = [
  { id: 'wildfly', passhash: '2c6368f4996288fcc621c5355d3e39b7' }
]

# Add application users to the hash 'app'  eg.
# 
default['wildfly']['users']['app'] = [
  { id: 'wildfly', passhash: '2c6368f4996288fcc621c5355d3e39b7' }
]

# Add application roles eg.
# 
default['wildfly']['roles']['app'] = [
  { id: 'wildfly', roles: 'role1,role2' }
]
