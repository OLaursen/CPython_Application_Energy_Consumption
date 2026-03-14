#!/bin/bash

#install dependencies
sudo pacman -S --needed bash base-devel git openssl zlib xz libffi bzip2 readline sqlite tk ncurses gdbm libnsl

curl https://pyenv.run | bash

# Set pyenv in path
cat << 'EOF' >> ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi
EOF

source ~/.bashrc

# Install Python versions via pyenv
VERSIONS=("3.13.7" "3.12.11" "3.11.13" "3.10.18" "3.9.23")
for VERSION in "${VERSIONS[@]}"; do
    PYTHON_BIN="$HOME/.pyenv/versions/$VERSION/bin/python"
    pyenv install $VERSION
    $PYTHON_BIN -m pip install pyperformance

done

echo "Python installation and setup complete!"