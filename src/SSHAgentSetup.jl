
"""
    SSHAgentSetup

A tool to setup `ssh-agent`.

# Usage

```julia
import SSHAgentSetup

SSHAgentSetup.setup()
SSHAgentSetup.add_key(joinpath(homedir(), ".ssh", "id_rsa"))
```
"""
module SSHAgentSetup

"""
    parse_ssh_agent_variables(ssh_agent_output::AbstractString) :: Dict{String, String}

Parses the result from command `ssh-agent -s` as variables `SSH_AUTH_SOCK` and `SSH_AGENT_PID`.

# Example

```julia
str = "SSH_AUTH_SOCK=/tmp/ssh-Spqsh9i4sw6Z/agent.4558; export SSH_AUTH_SOCK;\nSSH_AGENT_PID=4559; export SSH_AGENT_PID;\necho Agent pid 4559;"
result = SSHAgentSetup.parse_ssh_agent_variables(str)
@assert result["SSH_AUTH_SOCK"] == "/tmp/ssh-Spqsh9i4sw6Z/agent.4558"
@assert result["SSH_AGENT_PID"] == "4559"
```
"""
function parse_ssh_agent_variables(ssh_agent_output::AbstractString) :: Dict{String, String}

    rgx = r"SSH_AUTH_SOCK=(?<SSH_AUTH_SOCK>[^;]+)[\S\s]*SSH_AGENT_PID=(?<SSH_AGENT_PID>\d+)"
    m = match(rgx, ssh_agent_output)

    result = Dict{String, String}()

    for expected_key in (:SSH_AUTH_SOCK, :SSH_AGENT_PID)
        !haskey(m, expected_key) && error("Failed to parse `$expected_key` from `ssh-agent` output")
        result[string(expected_key)] = m[expected_key]
    end

    return result
end

"""
    is_agent_up() :: Bool

Checks wether `ssh-agent` is running.

Looks for `SSH_AUTH_SOCK` environment variable.
"""
function is_agent_up() :: Bool
    return get(ENV, "SSH_AUTH_SOCK", nothing) !== nothing
end

"""
    kill_agent()

Runs `ssh-agent -k` to kill the current agent,
and unset env variables `SSH_AUTH_SOCK` and `SSH_AGENT_PID`.
"""
function kill_agent()
    if is_agent_up()
        @info("Killing ssh-agent")
        run(`ssh-agent -k`)
        delete!(ENV, "SSH_AUTH_SOCK")
        delete!(ENV, "SSH_AGENT_PID")
    end

    nothing
end

"""
    setup(; kill_agent_atexit::Bool=false)

Runs `ssh-agent -s` and exports env variables `SSH_AUTH_SOCK` and `SSH_AGENT_PID`
with the result from that command.
"""
function setup(; kill_agent_atexit::Bool=false)
    if is_agent_up()
        @info("ssh-agent is already present")
    else
        @info("starting ssh-agent")
        agent_data = parse_ssh_agent_variables(readchomp(`ssh-agent -s`))
        for (k, v) in agent_data
            @info("Exporting: `$k=$v`")
            ENV[k] = v
        end

        if kill_agent_atexit
            atexit(kill_agent)
        end
    end

    nothing
end

"""
    add_key(key_file::AbstractString)

Runs `ssh-add \$key_file`.
"""
function add_key(key_file::AbstractString)
    @assert isfile(key_file) "Key file `$key_file` not found"
    run(`ssh-add $key_file`)
end

end # module SSHAgentSetup
