DOCKER_COMPOSE_VERSION=1.21.2

function get_docker_compose() {
  sudo curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Linux-x86_64 -o /opt/bin/docker-compose

  echo "8a11713e11ed73abcb3feb88cd8b5674b3320ba33b22b2ba37915b4ecffdf042 /opt/bin/docker-compose" | sha256sum -c
  res=$?
}

res=1

cur_retries=0
max_retries=5

# res is initially 1; so this will execute atleast once
while (( res != 0 && ++cur_retries != max_retries ))
do
  echo "---------------------------------------------------------"
  echo "Attempting to Download Docker-Compose. Attempt $cur_retries/$max_retries."
  echo "---------------------------------------------------------"
  get_docker_compose
done

if (( cur_retries == max_retries )); then
  echo "---------------------------------------------------------"
  echo "Failed downloading Docker-Compose."
  echo "---------------------------------------------------------"
else
  sudo chmod a+x /opt/bin/docker-compose
fi
