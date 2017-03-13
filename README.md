## Openshift Nginx + PHP 7 Cartridge

A cartridge for openshift that uses NGINX and PHP 7 as the web server.


### Installation

To install this cartridge use the cartridge reflector when creating an app

[![Install Apache & PHP7 OpenShift](http://launch-shifter.rhcloud.com/launch/Install PHP7.svg)](https://openshift.redhat.com/app/console/application_type/custom?&cartridges[]=diy-0.1&initial_git_url=https://github.com/alexviean/openshift-webserver.git&name=php)

Or manually:

	rhc create-app myapp http://cartreflect-claytondev.rhcloud.com/github/alexviean/openshift-webserver
	
### Configuration

The <code>public/</code> folder is the root document served by default. However, as can be seen in the <code>nginx.conf.erb</code> file it
is entirely configurable and only exists as a form of documentation.