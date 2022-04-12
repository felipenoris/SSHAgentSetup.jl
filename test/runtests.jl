
using Test
import SSHAgentSetup

@testset "parse_ssh_agent_variables" begin
    str = "SSH_AUTH_SOCK=/tmp/ssh-Spqsh9i4sw6Z/agent.4558; export SSH_AUTH_SOCK;\nSSH_AGENT_PID=4559; export SSH_AGENT_PID;\necho Agent pid 4559;"
    result = SSHAgentSetup.parse_ssh_agent_variables(str)

    expected_result = Dict{String, String}(
            "SSH_AUTH_SOCK" => "/tmp/ssh-Spqsh9i4sw6Z/agent.4558",
            "SSH_AGENT_PID" => "4559",
        )

    for (k, v) in expected_result
        @test haskey(result, k)
        @test result[k] == v
    end
end
