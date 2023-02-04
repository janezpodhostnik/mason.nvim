local Pkg = require "mason-core.package"
local platform = require "mason-core.platform"
local _ = require "mason-core.functional"
local github = require "mason-core.managers.github"
local std = require "mason-core.managers.std"

local coalesce, when = _.coalesce, _.when

return Pkg.new {
    name = "cadence-language-server",
    desc = [[Cadence Language Server]],
    homepage = "https://github.com/onflow/cadence",
    languages = { Pkg.Lang.Cadence },
    categories = { Pkg.Cat.LSP },
    install = function(ctx)
        local repo = "onflow/flow-cli"
        local function asset_file(version)
            return ("flow-cli-%s-%s"):format(
                version,
                coalesce(
                    when(platform.is.mac_arm64, "darwin-arm64.tar.gz"),
                    when(platform.is.mac_x64, "darwin-amd64.tar.gz"),
                    when(platform.is.linux_x64, "linux-amd64.tar.gz"),
                    when(platform.is.win_x64, "windows-amd64.zip")
                )
            )
        end
        local bin = "flow-cli"

        platform.when {
            unix = function()
                github
                    .untargz_release_file({
                        repo = repo,
                        asset_file = asset_file
                    })
                    .with_receipt()
                std.chmod("+x", { "flow-cli" })
            end,
            win = function()
                github
                    .unzip_release_file({
                        repo = repo,
                        asset_file = asset_file
                    })
                    .with_receipt()
                bin = "flow-cli.exe"
            end
        }

        ctx:link_bin(
            bin,
            ctx:write_shell_exec_wrapper(
                bin,
                ("%s cadence language-server"):format(bin)
            )
        )
    end,
}
