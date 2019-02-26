# Super Saltstack Demo

Vagrant boxes to run a silly orchestration demo.

## Setup

Install vagrant, then run `vagrant up`.

Two VMs will start - a salt-master, and a minion running nginx to serve a basic web page.

For the purposes of this demo, they will NOT be communicating yet.
The VMs will not be provisioned.

Additionally, the host machine running vagrant should have a
salt-minion and a webcam reachable with the `imagesnap` command.
A suitable minion config for the machine is at `minion/host`.
This minion should have an id of `super-saltstack-host`.

For the purposes of the demo, the minions should be added manually to
the master with `salt-key`.
They should try to connect to the master automatically.

Then run `sudo salt \* state.highstate` to get everything set up.

You can optionally run `./reset.sh` on the master to deprovision the
web minion, but without uninstalling any packages.
The demo will then work without internet, providing you have run
highstate before the reset script.
`./reset_all.sh` will do this and also disconnect all minions with `salt-key`.

## Run the demo

Visit `192.168.4.3` in a browser (the web minion). Connection denied.

`vagrant ssh master` and `tmux`.

Watch the salt event bus in a pane with `sudo salt-run state.event pretty=True`.

In another pane, check the minions are connected, accepting new
connections with `salt-key`, and potentially starting the salt-minion
on the host.

Verify the beacon is setup on the master with `sudo salt \* beacons.list`.
If not, run `sudo salt \*master state.sls beacon.motd`.

Edit `/home/vagrant/motd.txt` to set off the following sequence:

* An update to `/home/vagrant/motd.txt` on the master will cause a
  beacon event to fire.
* The salt reactor will notice this event and trigger an orchestrate
  runner. This runner will copy the modified file to the web minion,
  then run highstate on the web minion, creating a static html file
  served by nginx. The contents of `motd.txt` will be added to this
  file.
* When the highstate on the web minion has completed, another reactor
  will trigger another orchestrate runner, which will take a picture
  using `imagesnap` on the host minion.
* This picture will be grabbed by salt and placed in the nginx web
  root on the web minion.

Visit `192.168.4.3` again. A page should be returned with the message
from `motd.txt` and the recently taken picture!

Run `./reset.sh` to tear down the web server and start the demo again.
