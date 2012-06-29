define github::key (
  $path = undef,
  $token = undef,
  $type = 'user',
  $name = undef,
  $systemuser = undef
) {
  $keypath = "${path}/${name}-github"

  exec { "github::ssh-keygen":
    command => "ssh-keygen -q -f ${name}-github -b 2048 -N '' -C ''",
    creates => $keypath,
    user    => $systemuser,
    cwd     => $path,
    path    => ["/usr/bin"]
  } ->
  file { "github::ssh/config":
    name    => "${path}/config",
    ensure  => file,
    owner   => "staticly",
    content => "Host gh-${name}
  Hostname github.com
  User git
  IdentityFile ${keypath}"
  }

  file { "${path}/known-hosts":
    ensure => file,
    owner  => "staticly",
    group  => "staticly",
    source => "puppet:///modules/github/known_hosts"
  }

  if $type == 'user' {
    $url = "/user/keys"
  } else {
    $url = "/repo/$repo/keys"
  }

  github_api_request { "${url}":
    ensure   => present,
    params   => { "title" => $title, "key" => "read_file:${keypath}.pub" },
    token    => $token,
    require => Exec["github::ssh-keygen"]
  }

}
