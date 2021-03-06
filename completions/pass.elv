use github.com/zzamboni/elvish-completions/comp
use re
use str

config-files = [ ~/.ssh/config /etc/ssh/ssh_config /etc/ssh_config ]

fn -password-files {
    ls ~/.password-store/ | each [x]{
        str:trim-suffix $x '.gpg'
    }
}

pass-opts = []

fn -pass-completions [arg &suffix='']{
  user-given = (str:join '' [(re:find '^(.*@)' $arg)[groups][1][text]])
  -password-files | each [host]{ put $user-given$host } | comp:decorate &suffix=$suffix
}

edit:completion:arg-completer[pass]  = (comp:sequence &opts=$pass-opts [$-pass-completions~])
