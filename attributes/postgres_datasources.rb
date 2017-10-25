# frozen_string_literal: true

default['wildfly']['postgresql']['jndi']['datasources'] = [
  {
    pool_name: 'test',
    jndi_name: 'java:jboss/datasources/test',
    server: '127.0.0.1',
    port: '5432',
    db_name: 'test',
    db_user: 'test_user',
    db_pass: 'test_pass',
    pool_min: '5',
    pool_max: '20'
  },
  {
    pool_name: 'test2',
    jndi_name: 'java:jboss/datasources/test2',
    server: '127.0.0.1',
    port: '5432',
    db_name: 'test2',
    db_user: 'test_user',
    db_pass: 'test_pass',
    pool_min: '5',
    pool_max: '20'
  }
]
