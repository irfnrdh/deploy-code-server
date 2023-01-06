# Start from the code-server Debian base image
FROM codercom/code-server:4.9.0

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install Node.js
# RUN \
#   cd /tmp && \
#   wget http://nodejs.org/dist/node-latest.tar.gz && \
#   tar xvzf node-latest.tar.gz && \
#   rm -f node-latest.tar.gz && \
#   cd node-v* && \
#   ./configure && \
#   CXX="g++ -Wno-unused-local-typedefs" make && \
#   CXX="g++ -Wno-unused-local-typedefs" make install && \
#   cd /tmp && \
#   rm -rf /tmp/node-v* && \
#   npm install -g npm && \
#   printf '\n# Node.js\nexport PATH="node_modules/.bin:$PATH"' >> /root/.bashrc

# Install NodeJS
RUN sudo curl -fsSL https://deb.nodesource.com/setup_16.x | sudo bash -
RUN sudo apt-get install -y nodejs 
#&& npm install --global yarn 
   
# Set instructions on build.
# ONBUILD ADD package.json /app/
# ONBUILD RUN npm install
# ONBUILD ADD . /app

# Define working directory.
# WORKDIR /app

# Define default command.
# CMD ["npm", "start"]


# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
RUN code-server --install-extension pkief.material-icon-theme \
    code-server --install-extension akamud.vscode-theme-onedark \
    code-server --install-extension mhutchie.git-graph
    
# RUN  for codextension in \
#      pkief.material-icon-theme \
#      akamud.vscode-theme-onedark \
#      christian-kohler.npm-intellisense \
#      formulahendry.code-runner \
#      seunlanlege.action-buttons \
#      coenraads.bracket-pair-colorizer-2 \
#      yzhang.markdown-all-in-one \
#      auchenberg.vscode-browser-preview \
#      ; do code-server --install-extension $codextension --extensions-dir $CUSTOM_HOME/.extensions; done  \


# Install apt packages:
# RUN sudo apt-get install -y ubuntu-make

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool
COPY container/code-server/pages/ /usr/lib/code-server/src/browser/pages/
# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
