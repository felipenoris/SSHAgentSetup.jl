# SSHAgentSetup.jl

A tool to setup `ssh-agent`.

# Usage

```julia
import SSHAgentSetup

# starts `ssh-agent`
SSHAgentSetup.setup()

# uses `ssh-add` to add user key to ssh agent
SSHAgentSetup.add_key(joinpath(homedir(), ".ssh", "id_rsa"))
```
