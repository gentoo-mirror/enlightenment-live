# enlightenment-live

Enlightenment WM latest stable version and live ebuilds

## Usage

Add repository using layman.

    layman -a enlightenment-live

Install the latest enlightenment git master.

    emerge -av @enlightenment-core-9999

## Package ebuild admission guidelines

Package ebuilds eligible for this overlay:

  * Live packages for git master and branches
     - enlightenment-9999 (live git master)
     - e.g. enlightenment-0.20.9999 (live git 0.20 branch)
  * Released versions as long as they aren't included in the official
    gentoo repository.
  * Important snapshots.

Additional requirements for each ebuild.

  * It must be buildable at the time of inclusion and reasonable effort
    must be taken to keep it buildable in the long term.

Package ebuilds that are not buildable should be either fixed or removed.

Note that in the **examples** directory you can find package.keywords and package.use enlightenment files to use.
You can simple link to this files from /etc/portage/package.use/ and from /etc/portage/package.keywords/
