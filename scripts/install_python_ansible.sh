ACTIVE_PYTHON_VERSION=3.6.0.3600

# Download ActivePython
function get_active_python() {
  curl -L https://downloads.activestate.com/ActivePython/releases/$ACTIVE_PYTHON_VERSION/ActivePython-$ACTIVE_PYTHON_VERSION-linux-x86_64-glibc-2.3.6-401834.tar.gz -o ActivePython.tar.gz

  echo "edd17d3221d9744fe27d37842b325f55d0261e69073de3be54e29c1806fe57ae ActivePython.tar.gz" | sha256sum -c
  res=$?
}

# Extract and install ActivePython
function install_active_python() {
  mkdir ActivePython
  tar -C ActivePython --strip-components=1 -xvf ActivePython.tar.gz

  sudo mkdir -p /opt/bin/active_python
  sudo ActivePython/install.sh -I /opt/bin/active_python
  rm -rf ActivePython
  rm ActivePython.tar.gz
}

# Python and PIP symlinks
function create_symlinks() {
  sudo ln -sf /opt/bin/active_python/bin/easy_install /opt/bin/easy_install

  sudo ln -sf /opt/bin/active_python/bin/python3 /opt/bin/python3
  sudo ln -sf /opt/bin/active_python/bin/python3.6 /opt/bin/python3.6
  sudo ln -sf /opt/bin/active_python/bin/python3.6 /opt/bin/python

  sudo ln -sf /opt/bin/active_python/bin/pip3 /opt/bin/pip
}

function install_ansible() {
  sudo pip install ansible
  sudo ln -s /opt/bin/active_python/bin/ansible /opt/bin/ansible
}

# res verifies checksum for downloaded ActivePython archive
res=1

cur_retries=0
max_retries=5

# res is initially 1; so this will execute atleast once
while (( res != 0 && ++cur_retries != max_retries ))
do
  echo "---------------------------------------------------------"
  echo "Attempting to Download ActivePython. Attempt $cur_retries/$max_retries."
  echo "---------------------------------------------------------"
  get_active_python
done

if (( cur_retries == max_retries )); then
  echo "---------------------------------------------------------"
  echo "Failed downloading ActivePython."
  echo "---------------------------------------------------------"
else
  install_active_python
  create_symlinks

  # Because ActivePython doesn't necessarily have the latest PIP version
  sudo pip install --upgrade pip

  install_ansible
fi
