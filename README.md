# Launch VS Code Remote-SSH from a compute session on clusters

If you need to work on clusters to satisfy your compute need, VS Code Remote-SSH is a great extension for allowing you to connect to your cluster using VSCode, browse files, and run things interactively. However, this does require quite a bit of resource on the cluster, and if you connect the seesion directly on the login node, this can cause a slow down for everyone as the log in node may not have a lot of compute resources.

A recommended way to do it is to run it through a compute session through proxy jump - you would request a compute node first, then use proxy jump to connect to that compute node and run your VSCode session there. This will free up the precious resources on the log in node for everyone while still let you use all the functionality of the extension. However, it is tedeious to do that as you need to excecute a series of commands before you connect your VSCode session using proxy jump. What if you can just do that in 1 simple script?

## Set up the script
1. Clone to repo to anywhere you want on your local machine
2. Ensure you have your cluster log in node set up in ``~/.ssh/config``
3. Change the following argument in the ``launch_vscode_on_compute.sh`` script:
   - REMOTE_USER (both instances, your killarney user name)
   - WORKING_DIR (your vscode landing directory) 
   - SLURM_ARGS (your resource allocation requirement)
4. Set up the proxy jumps by adding the following to your ``~/.ssh/config``
```
Host *
  ProxyJump your_login_host
  User your_user
  IdentityFile your_identity # skip this if use passwords to log in
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel ERROR
```
## Using the script
Every time that you want to start working, simply run:

``bash launch_vscode_on_compute.sh``

And wait (and enter password and/or approve Duo prompt whenever being prompted to do so). The script will automatically log into your log in node, start requesting resources if no existing resource is available, and connect to it via Remote-SSH once a node is allocated to you.

Happy computing!
