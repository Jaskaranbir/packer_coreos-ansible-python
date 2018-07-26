DOCKER_COMPOSE_VERSION=1.22.0

function get_docker_compose() {
  sudo curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Linux-x86_64 -o /opt/bin/docker-compose

  echo "f679a24b93f291c3bffaff340467494f388c0c251649d640e661d509db9d57e9 /opt/bin/docker-compose" | sha256sum -c
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
