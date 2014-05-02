# Union

CI with smarts. ^_^

## Installation and self-deployment

### Requirements
  * Ruby version 2.1.1 (>= 1.9.3 should work, but not tested).
  * Mysql Server (in Ubuntu, run `sudo apt-get install mysql-server`).

It is suggested that you create a non-privileged user to run your application. For example, let's assume you create a
user with the name *union*. You should generate an SSH key for this user with ``union$ ssh-keygen -t rsa`` and give read
access to your git server for user *union* with its SSH public key.

### Installation steps
Clone git repository

    git clone https://github.com/mobmewireless/union.git
    bundle install --deployment

Set up essential environment variables as configuration before starting your application. You can do this via your web
server, or alternatively by creating a ``.env`` file in the root directory, and entering values listed in this README under
[Environment Variables](#environment-variables).

Then perform DB setup and asset pre-compilation:

    bundle exec rake db:setup
    bundle exec rake assets:precompile

...and run with your favorite Rack-compatible web server.

For setting up daemons, use foreman:

    rvmsudo bundle exec foreman export upstart /etc/init -a infrastructure-union -u union -d /home/union/deploy/infrastructure-union/current
    sudo start infrastructure-union

## Deployment using Union

### Server Customization

The target servers should have two user accounts: one for running deployed applications and the other for deployment.
Let's assume that the application user is *union*, and that the deployment user is *deploy*, added to the group of
application user.

    sudo adduser deploy --ingroup union

Assuming Union executes as user *union*, you'll have to add its SSH public key to the target server's deploy user's
authorized keys file.

    unite$ ssh-copy-id deploy@target-server

Create directory ``deploy`` on *union* user's home directory and make it group-writable.

    mkdir /home/union/deploy
    chmod g+w -R /home/union/deploy

### Deployment of repository

For deploying an application create a file ``deploy/config.yml`` in application root. See
[example configuration](https://github.com/mobmewireless/union/tree/master/examples/deploy_fully_explained) for help.
Commit this file, and any optional after_* files, and push it upstream. You'll have to map hostname of target server to
its IP in /etc/hosts of server hosting Union.

Now login to Union with one of the admin emails address that you configured. Create a new project with application's git
URL - it will fetch deployment server details from ``deploy/config.yaml``. Go to the project's page and click
``Actions > Setup``, this will setup the basic directory structure and shared directory. Now for deployment use
``Actions > Deploy``. You can also do this from the home page.

### Self deployment

Union can deploy itself (!). Just fork Union from github, add and commit a ``deploy/config.yml`` with your Union server
details, including path to existing deployment, making sure that user set up is as per recommendations, and follow above
steps.

See [/examples/deploy_unite_example](https://github.com/mobmewireless/union/tree/master/examples/deploy_unite_example)
for an example *deploy* folder for your fork.

### Assumptions (Roundup)

  * Deploys happen via user 'deploy' at production servers.
  * The deployment server authenticates itself to the Git repo via its SSH key (of *union* user).
  * The deployment server authenticates itself to *deploy* user of the production server via its SSH key (of *union* user).
  * A repository branch can be deployed to multiple production servers.
  * For ruby application deployments, *Git Deploy* assumes RVM has been installed in multi-user mode in production server.

## Overview of the deployment process

Before both ``setup`` and ``deploy``

  * Clones or updates repository for selected project.

When performing *Setup*:

  1. Creates deployment folder.
  2. Creates shared folder inside deployment folder.
  3. Execute ``deploy/after_setup`` from deployment folder path.

When performing *Deploy*:

  1. Creates cache directory on remote server (if it doesn't exist).
  2. Sync local cache to remote cache.
  3. Copies non-existent (rename, if necessary) shared files from sync-ed remote cache to shared folder.
  4. Copy remote cache directory to form new deployment directory.
  5. Link shared files to directory created in step 4.
  6. Execute ``deploy/after_upload`` from path of directory created in step 4.
  7. Point ``current`` symlink to directory created in step 4.
  8. Execute ``deploy/after_deploy`` from the ``current`` directory path.

## Testing
### Manual
To execute all tests manually, run:

    bundle exec rake spec

### RubyMine (using Zeus)
To execute tests from within RubyMine, create a shell script `/script/startzeus` (gitignored) with the following
contents and execute it:

    env RUBYLIB=/path/to/RubyMine-6.x/rb/testing/patch/common:/path/to/RubyMine-6.x/rb/testing/patch/bdd zeus start

Then, in RubyMine, go to *Run* >> *Edit Configurations* >> *Defaults* >> *RSpec*, and turn on *Use custom RSpec Runner
Script* and point it to `/script/rspec_runner.rb`.

Now right-click on either the spec directory in the Project view (or any inner directory / file), and choose the
*Run Specs* option.

## Environment Variables

Also see ``.env.example`` file in project root.

### Essentials
*  **UNION_ROOT**: Absolute path to root of your deployment of Union.
*  **UNION_SECRET_TOKEN**: Web application's secret token. Generate one with the `rake secret` command.
*  **UNION_DB_NAME**: Name of production / development database server.
*  **UNION_DB_USERNAME**: Username with which to connect to production / development database.
*  **UNION_DB_PASSWORD**: Password with which to connecto to production / development database.
*  **UNION_DB_HOST**: Hostname / IP of production /development database server.
*  **UNION_ALLOWED_EMAIL_HOST**: Allows hosts e-mail addresses from this host to access the interface. For example: 'yourcompany.com'.
*  **UNION_ADMIN_EMAILS**: Comma separated administrator emails.
*  **GOOGLE_CLIENT_ID**: Google client for oauth ( Required in production ).
*  **GOOGLE_CLIENT_SECRET**: Google client secret for oauth ( Required in production ).

### Trello Integration
*  **TRELLO_API_KEY**: API Key supplied by trello identifying your instance of the application.
*  **TRELLO_API_SECRET**: API Secret supplied by trello, used in verifying source of requests to webhook callback URL.
*  **TRELLO_API_TOKEN**: API Token generated for the above API key, authorizing read and write permissions on the board you
   wish to create reports on.
*  **TRELLO_WEBHOOK_CALLBACK_URL**: URL supplied to Trello as Webhook callback URL.

### Testing
*  **UNION_TEST_DB_NAME**: Name of test database.
*  **UNION_TEST_DB_USERNAME**: Username with which to connect to test database.
*  **UNION_TEST_DB_PASSWORD**: Password with which to connect to test database.
*  **UNION_TEST_DB_HOST**: Hostname / IP of test database server.

### API access
*  **UNION_API_ACCESS_TOKENS**: Secret token to host mapping for API access.

### OSSEC Logs collection
*  **OSSEC_COLLECTOR_PATH**: Path to OSSEC collector in servers if it's being used.

### Optional
*  **UNION_SESSION_STORE_KEY**: Optional. Sets application's session store key. Defaults to '_union_session'.
