# install and configure fpm for the building of RPMS
class packagebuild {

  file { '/opt':
    ensure => directory,
    owner  => vagrant,
    group  => vagrant,
  }

  file { '/var/cache/omnibus':
    ensure => directory,
    owner  => vagrant,
    group  => vagrant,
  }

  $ruby_pkgs = [ 'ruby1.9.1-dev', 'ruby1.9.1', 'rubygems', 'ruby-rvm' ]

  package { $ruby_pkgs:
    ensure => latest,
    notify => Exec['update-ruby'],
  }

  # Omnibus requires ruby 1.9 or later
  exec { 'update-ruby':
    refreshonly => true,
    command     => '/usr/sbin/update-alternatives --set ruby /usr/bin/ruby1.9.1 ; /usr/sbin/update-alternatives --set gem /usr/bin/gem1.9.1 ',
    user        => "root",
  }

  package { 'fpm':
    ensure   => latest,
    provider => gem,
    require  => [ Package[$ruby_pkgs], Exec['update-ruby'] ],
  }

  package { 'omnibus':
    ensure   => latest,
    provider => gem,
    require  => [ Package[$ruby_pkgs], Exec['update-ruby'] ],
  }

  package { 'bundler':
    ensure   => latest,
    provider => gem,
    require  => [ Package[$ruby_pkgs], Exec['update-ruby'] ],
  }


  $build_utils = [ 'build-essential', 'libpcre3-dev', 'unzip', 'libxml2-dev', 'libxslt1-dev', 'libgd2-xpm-dev', 'libgeoip-dev', 'python-setuptools', 'libgecode-dev' ]

  package { $build_utils:
    ensure  => latest,
    require => Package['fpm'],
  }

  $java_pkgs = [ 'tzdata-java', 'openjdk-7-jre-headless', 'openjdk-7-jre', 'openjdk-7-jdk' ]

  package { $java_pkgs:
    ensure  => latest,
  }

  # Mono build requirements

  $mono_build_essentials = [ 'mono-runtime', 'xsltproc', 'automake', 'gettext', 'libtool', 'autoconf', 'g++', 'libglib2.0-dev', 'libpng12-dev',
                             'libfreetype6-dev', 'libfontconfig1-dev', 'libx11-dev', 'libjpeg8-dev', 'libgif-dev', 'libexif-dev' ]

  $mongodb_build = [ 'scons', 'libssl-dev' ]

  package { $mono_build_essentials: 
    ensure => latest,
  }

  package { $mongodb_build:
    ensure => latest,
  }

}
