Enable TDX feature on Ubuntu 23.10
--

This procedure shows how to enable the TDX feature on host and guest
on top of Ubuntu 23.10

Enable TDX feature on host
-----

- Deploy Ubuntu 23.10 cloud image on the server

  https://cloud-images.ubuntu.com/mantic/current/mantic-server-cloudimg-amd64.img

  If you are not able to deploy image on the server, you can try to install it from
	an ISO:

	https://cdimage.ubuntu.com/ubuntu-server/daily-live/20230927/mantic-live-server-amd64.iso
	
- Run the script

  $ sudo ./setup-host.sh

- Reboot

- Check TDX enablement

  $ ./utils/check-tdx-host.sh

Start TD VM
-----

- Download the guest image

  https://people.canonical.com/~hector/kobuk/tdx/guest/tdx-guest.qcow2

  Put the qcow2 file into the current folder under the name : tdx-guest.qcow2
	
- Start the TD VM

  $ ./run_td.sh


The TD VM can be accessed via SSH : ssh -p 10022 root@localhost


The password is 123456

