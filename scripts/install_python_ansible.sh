ACTIVE_PYTHON_VERSION=3.6.0.3600
ACTIVE_PYTHON_INSTALL_PATH=/opt/bin

# Download ActivePython
function get_active_python() {
  curl -L https://downloads.activestate.com/ActivePython/releases/$ACTIVE_PYTHON_VERSION/ActivePython-$ACTIVE_PYTHON_VERSION-linux-x86_64-glibc-2.3.6-401834.tar.gz -o ActivePython.tar.gz

  echo "edd17d3221d9744fe27d37842b325f55d0261e69073de3be54e29c1806fe57ae ActivePython.tar.gz" | sha256sum -c
  res=$?
}

# Extract and install ActivePython
function install_active_python() {
  echo "=> Installing ActivePython."
  mkdir ActivePython
  tar -C ActivePython --strip-components=1 -xvf ActivePython.tar.gz

  # Unpack and install ActivePython
  sudo mkdir -p $ACTIVE_PYTHON_INSTALL_PATH/active_python
  sudo ActivePython/install.sh -I $ACTIVE_PYTHON_INSTALL_PATH/active_python
  sudo rm -rf ActivePython
  sudo rm ActivePython.tar.gz

  sudo ln -sf $ACTIVE_PYTHON_INSTALL_PATH/active_python/bin/python3.6 /opt/bin/python

  echo "=> Adding ActivePython binaries to PATH."
  # Local .bashrc is read-only a symlink by default
  rm $HOME/.bashrc
  touch $HOME/.bashrc
  sudo chmod 644 $HOME/.bashrc

  # Add custom-binaries directory to PATH
  custom_path=$ACTIVE_PYTHON_INSTALL_PATH
  # Add installed PIP packages to local PATH
  custom_path=$custom_path:$ACTIVE_PYTHON_INSTALL_PATH/active_python/bin
  # Update PATH using bashrc
  echo "export PATH=$PATH:$custom_path" >> $HOME/.bashrc
  source $HOME/.bashrc
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
  echo "-------------------------------------------------- -------"
  echo "Failed downloading ActivePython."
  echo "---------------------------------------------------------"
else
  install_active_python

  # Set current PATH for sudo also
  # This will also make "pip" command available, instead of "pip3"
  sudo env "PATH=$PATH" pip3 install --upgrade pip

  echo "=> Installing Ansible."
  sudo env "PATH=$PATH" pip --version
  sudo env "PATH=$PATH" pip install ansible
fi
