use github.com/zzamboni/elvish-completions/comp
use re
use str

var config-files = [ ~/.ssh/config /etc/ssh/ssh_config /etc/ssh_config ]

fn -password-files {
    ls ~/.password-store/ | each {|x|
        str:trim-suffix $x '.gpg'
    }
}

var pass-opts = []

fn -pass-completions {|arg &suffix=''|
  var user-given = (str:join '' [(re:find '^(.*@)' $arg)[groups][1][text]])
  -password-files | each {|host| put $user-given$host } | comp:decorate &suffix=$suffix
}

set edit:completion:arg-completer[pass]  = (comp:sequence &opts=$pass-opts [$-pass-completions~])
