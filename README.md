#kvmtools-perl

`kvmtools` provides easy command line tools to create, clone and
destroy virtual machines. Everything kvmtools can do, can be done with
and requires the libvirt virtualization packages. It is simply a
wrapper around `virsh`, `qemu-img`, etc.

#Installing kvmtools-perl

**Clone the repo:**

		$ git clone git@github.com:jimmyjames85/kvmtools-perl.git
	
**Append the following to your .bashrc to include aliases:**

		KVMTOOLS_DIR='/path/to/cloned/repo/kvmtools-perl'
		source $KVMTOOLS_DIR/aliases.sh

**Reload your `.bashrc`**

		$ source ~/.bashrc


# Installing a VM from an ISO

These steps will install the minimal installation of CentOS-7-x86_64
from an
[ISO image](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1611.iso).

**Download the .iso, move it into the `/var/lib/libvirt/` directory,
  and begin the installation.**

		$ sudo wget $ISO_SRC_URL
		$ sudo mv CentOS-7-x86_64-Minimal-1611.iso /var/lib/libvirt
		$ kvmcreate iso /var/lib/libvirt/CentOS-7-x86_64-Minimal-1511.iso name vm-isoinstall
		
This will create a VM with the backing image inside
`/var/lib/libvirt/images`. You can view details using `kvmls`, but to
access it you will need to attach to the VM's console, with `sudo
virsh console vm-isoinstall` or `kvmconsole vm-isoinstall`. **View VM
details with `kvmls` and attach to the VM's console and continue the
installation:**

		$ kvmls
		$ kvmconsole vm-isoinstall
		$ # Note: If your screen doesn't refresh press 'r'. Applicable for Centos only.

Follow the on-screen directions for installing Centos, and be sure to
setup and verify the network configuration as well as the root
password. Once the installation is complete the VM will be shut
down. **View VM details and start up the VM by executing:**

		$ kvmls
		$ sudo virsh start vm-isoinstall

The VM will not have an IP untill it finishes booting (wait about 10
seconds). Afterwards you can view the IP address with `kvmip` or
`kvmls`, and login via ssh. **Login as root with `kvmssh` and
provision your new VM:**

		$ kvmssh vm-isoinstall
		> sudo yum install -y net-tools tree wget 
		> exit

# Create a base image from an existing VM

A base image is like a template. Once it is created it can be cloned
to create other VMs. **Create a base image from the `vm-isoinstall`
VM:**

		$ sudo virsh shutdown vm-isoinstall
		$ kvmls
		$ # wait for it to shutdown
		$
		$ kvmcreate basefrom vm-isoinstall dest /var/lib/libvirt/centos7-base.qcow2
		
# Create a thinclone from a base image

Creating a VM with the thinclone option will give it two backing
images. The base image must already exist, and a new *thin* image will
be created specifically for the new VM. Any changes made inside the VM
will be made to the new thinner image. Thus you can have one base
image support many thinclones. **Create a thinclone from your base
image:**

		$ kvmcreate thinclone /var/lib/libvirt/centos7-base.qcow2 dest /var/lib/libvirt/images/thin-clone-one.qcow2 name thin-clone-one
		$ kvmls
		$ # wait for the thin clone to get an IP
		$
		$ kvmssh thin-clone-one
		> which tree

# Create a hardclone from a base image

Creating a VM with the hardclone option gives it one backing image. It
essentially copies the base image and uses the copy as the backing
image. **Create a hardclone from your base image:**

		$ kvmcreate hardclone /var/lib/libvirt/centos7-base.qcow2 dest /var/lib/libvirt/images/hard-clone-one.qcow2 name hard-clone-one
		$ kvmls
		$ # wait for the hard clone to get an IP
		$
		$ kvmssh thin-clone-one
		> which tree

To see the difference between a hard and a thin clone look at the size
difference of the backing images. **View the differences in
`/var/lib/libvirt/images`:**

		$ sudo ls -lh /var/lib/libvirt/images
		  -rw-r--r-- 1 qemu qemu 1.3G Jan 30 02:13 hard-clone-one.qcow2
		  -rw-r--r-- 1 qemu qemu 8.2M Jan 30 02:13 thin-clone-one.qcow2

The thin clone is only 8.2 M whereas the hard clone is 1.3G !!!

# Setup quickcreate after creating a base image

Specifying all the arguments for `kvmcreate` can be cumbersome, and
`quickcreate` is a shortcut that creates thinclones from a pre-set
base image. Set this up once in your .bashrc and creating thinclones
is as easy as `quickcreate vmname`. **Update your .bashrc to include
the following:**

		KVMTOOLS_DIR='/path/to/cloned/repo/kvmtools-perl'
		QUICKCREATE_BASE_IMG='/var/lib/libvirt/centos7-base.qcow2'
		QUICKCREATE_DEST_FOLDER='/var/lib/libvirt/images'
		source $KVMTOOLS_DIR/aliases.sh

**Reload your `.bashrc`**

		$ source ~/.bashrc

**Create a thinclone using `quickcreate` or `qc`:**

		$ quickcreate thin-clone-two
		$ qc thin-clone-three
		$ kvmls

# Delete a Virtual Machine

`kvmrm` will attempt to destroy and undefine virtual machines. If
using the aliases.sh the --force command is implicit, otherwise, you
will be prompted for confirmation of the removal of the backing
images. **Delete the thin-clone-three VM:**

		$ kvmrm thin-clone-three
		$
		$ # and verify
		$
		$ kvmls
		$ sudo ls /var/lib/libvirt/images
