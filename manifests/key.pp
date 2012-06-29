define github::key (
  $path = undef,
  $token = undef,
  $type = 'user',
  $name = undef
) {
  $keypath = "${path}/${name}-github"

  exec { "github::ssh-keygen":
    command => "ssh-keygen -q -f ${name}-github -b 2048 -N '' -C ''",
    creates => $keypath,
    user    => $systemuser,
    cwd     => $path,
    path    => ["/usr/bin"]
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
