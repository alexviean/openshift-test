## Openshift Nginx + PHP 7 Cartridge

A cartridge for openshift that uses NGINX and PHP 7 as the web server.


### Installation

To install this cartridge use the cartridge reflector when creating an app

<a href="https://openshift.redhat.com/app/console/application_type/custom?cartridges%5B%5D=http://cartreflect-claytondev.rhcloud.com/github/alexviean/openshift-webserver&amp;name=php"><img alt="Run+PHP+7+on+OpenShift" src="https://launch-shifter.rhcloud.com/launch/light/Run%20PHP%207%20on.svg" /></a>

Or manually:

	rhc create-app myapp http://cartreflect-claytondev.rhcloud.com/github/alexviean/openshift-webserver

### Configuration

The <code>public/</code> folder is the root document served by default. However, as can be seen in the <code>nginx.conf.erb</code> file it
is entirely configurable and only exists as a form of documentation.