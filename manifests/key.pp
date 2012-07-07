define github::key (
  $path = undef,
  $token = undef,
  $type = 'user',
  $name = undef,
  $full_name = undef,
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

  exec { "github::ssh-known-hosts":
    command   => "ssh-keyscan -t rsa github.com >> /home/${systemuser}/.ssh/known_hosts",
    user      => $systemuser,
    logoutput => on_failure,
    cwd       => $path,
    path      => ["/usr/bin"]
  }

  if $type == 'user' {
    $url = "/user/keys"
  } else {
    $url = "/repos/$full_name/keys"
  }

  github_api_request { "${url}":
    ensure   => present,
    params   => { "title" => $title, "key" => "read_file:${keypath}.pub" },
    token    => $token,
    require => Exec["github::ssh-keygen"]
  }

}
