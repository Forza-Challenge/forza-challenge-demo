defmodule Mix.Tasks.DeployLatest do
  use Mix.Task

  @app :forza_challenge_demo
  @aws_ecr "068328715416.dkr.ecr.eu-north-1.amazonaws.com"
  @aws_iam_profile "forza-challenge-containers"

  @remote "ec2-user@ec2-13-51-70-188.eu-north-1.compute.amazonaws.com"
  @pem_file "~/.ssh/fcdemo.pem"

  def run(params) do
    # Build
    vsn = Keyword.fetch!(FCDemo.MixProject.project(), :version)

    info("Build docker image #{@app}:#{vsn}")
    :ok = shell_cmd("docker build . -q -t #{@app}:#{vsn}")

    info("Tag docker image #{@app}:#{vsn} as #{@app}:latest")
    :ok = shell_cmd("docker tag #{@app}:#{vsn} #{@app}:latest")

    # Push
    info("Pushing #{@app} docker image to #{@aws_ecr}...")

    info("Tag docker image #{@app}:latest as #{@aws_ecr}/#{@app}:latest")
    :ok = shell_cmd("docker tag #{@app}:latest #{@aws_ecr}/#{@app}:latest")

    info("Retrieve an authentication token and authenticate Docker client to registry")

    shell_cmd(
      "aws ecr get-login-password --profile #{@aws_iam_profile} | " <>
        "docker login --username AWS --password-stdin #{@aws_ecr}"
    )

    info("Push image to AWS repository")
    :ok = shell_cmd("docker push #{@aws_ecr}/#{@app}:latest")

    # pull, stop & run over SSH
    info("Authorize remote docker")
    :ok = ssh_remote_cmd("aws ecr get-login-password | sudo docker login --username AWS --password-stdin #{@aws_ecr}")

    info("Pull latest docker image")
    :ok = ssh_remote_cmd("sudo docker pull #{@aws_ecr}/#{@app}:latest")

    info("Remote container - stop latest")
    ssh_remote_cmd("sudo docker stop #{@app}")
    ssh_remote_cmd("sudo docker rm #{@app}_previous_version")
    ssh_remote_cmd("sudo docker container rename #{@app} #{@app}_previous_version")

    env_vars = Enum.map(params, &("-e" <> &1)) |> Enum.join(" ")

    info("Remote container - migration, env vars: #{env_vars}")
    :ok = ssh_remote_cmd("sudo docker run --rm #{env_vars} #{@aws_ecr}/#{@app}:latest eval \"FCDemo.Release.migrate\"")

    info("Remote container - start, env vars: #{env_vars}")
    :ok = ssh_remote_cmd("sudo docker run --name #{@app} -d -p8080:8080 #{env_vars} #{@aws_ecr}/#{@app}:latest start")
  end

  defp info(msg), do: Mix.shell().info("\x1b[34m#{msg}\x1b[0m")

  defp shell_cmd(cmd) do
    if Mix.shell().cmd(cmd) == 0, do: :ok, else: :error
  end

  defp ssh_remote_cmd(cmd) do
    if Mix.shell().cmd("ssh -i #{@pem_file} #{@remote} \"#{cmd}\"") == 0, do: :ok, else: :error
  end
end
