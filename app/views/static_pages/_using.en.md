# Using

Development is done on Mac, below are instructions:

### Requirements:

1. install [Homebrew](https://brew.sh)
2. install [JDK  8](http://www.oracle.com/technetwork/java/javase/downloads/index.html)
3. install [JCE (Java Cryptographic Extensions)](https://en.wikipedia.org/wiki/Java_Cryptography_Extension)  
  - Download the JCE   
  - Execute `/usr/libexec/java_home` to find Java Home. Switch to that directory and then drill into `jre/lib/security` from there.  
  - Copy the JCE's `local_policy.jar` and `US_export_policy.jar` and overwrite the JDK one's  
4. Install [JRuby](http://jruby.org) with Homebrew: `brew install jruby`

### Running:
1. Install all the gems: `bundle install`
2. Set up Databaseses: `jruby -S bundle exec rake db:create db:schema:load RAILS_ENV=development` (change env to `production` if in production)
3. Set up the Secret files (see below)
4. Start the Rails Server: `rails s`


# Deploy

## Deploying to Tomcat 

### Requirements:

1. Tomcat  (ver. 7 or higher)
2. Java 8 (7 might be compatible)
3. Java Cryptographic Extensions (for Java 7 & 8)

### Setting up the Secret files
Before creating the War file you must generate all the secret files if you haven't generated them yet.
The following text files contain template files of the yaml files:
1. `config/database.yml.txt` --> `database.yml`
2. `config/secrets.yml.txt`  --> `secrets.yml`

Using those templates:
1. Generate the `secret_key_base` in the `secrets.yml` file you can run `rake secret`.
2. Add the database connection info to `database.yml` and create the database tables if they don't exist(`rake db:create && rake db:migrate`).
3. Generate the Devise key. Devise requires a secret at: `config/initializers/devise.rb` for `config.secret_key` there is a comment on the file but replace the key.
4. Optionally, generate or update the `bin` directory with `rake rails:update:bin` if necesary (only for war file deploys). 

### Generating a War file for deployment

1. revise warble configuration at `config/warble.rb`, `config/initializers/production.rb` & `config/application.rb`
2. run `rake assets:precompile` if needed
3. run `warble` (to see options run `warble -T`)

### Deploying on Tomcat for testing on a Mac

1. install tomcat with homebrew `brew install tomcat`
2. run the rake task to set up tomcat user files `rake tomcat:setup_mac`
3. run tomcat server `catalina run`
4. use the managment page to import warbler war file `localhost:8080` or
5. put war file in this locale `/usr/local/Cellar/tomcat/{{version}}/libexec/webapps/`
6. optionally, set up [MailCatcher gem](mailcatcher.me) to recieve the mailers.

### Deploying on Tomcat for production on Ubuntu

1. install tomcat `sudo apt-get install tomcat8 tomcat8-admin`
2. set up tomcat's user files
3. put war file on this directory: `/var/lib/tomcat8/webapps`
4. run tomcat: `sudo service tomcat8 {stop|start|restart}`
5. set up smtp or mail delivery
5. optionally set up Pound (proxy) to handle certificates. 

### Deploying on Windows<sup>1</sup> with Tomcat

1. install apache tomcat8
2. make sure there are no spaces or special charaters on the tomcat path.
3. set **Tomcat Server Heap Memory** up on the Java tab in Windows (Rails 4.1 requirement).
   - `-XX:MaxPermSize=256M`
   - `-XX:PermSize=256M`
   - `-Xmx1024m` (possibly can be lower, like 512m)
   - `-Dfile.encoding=UTF-8` (windows only for UTF-8 compatibility)
4. set up tomcat's user files
5. put war file in the webapps directory
6. set up smtp or mail delivery

### Pound:
Pound is a reverse proxy. It can be used to resolve the https certificates (if needed) and forward port 80 calls to port 8080 of tomcat. If you have more than one server it can serve as a rudimentary load balancer.

1. `sudoedit /etc/pound/pound.cfg`
ListenHTTP is the ip and port it listens on. Use port '80'.
Service Backend (there can be more than one) is the server. Use port '8080'. Specify a Priority if using more than one.
2. `sudoedit /etc/default/pound`
Change `startup=0` to `startup=1`
3. `sudo service pound start`

Pound can also handle certificates.

#### Certificates for https with pound
[How To link](http://www.project-open.org/en/howto_pound_https_configuration) (external link)

# Notes
- Ubuntu: `sudo service tomcat7 {stop|start|restart}`
- Ubuntu: ROOT is in `/var/lib/tomcat8/ROOT`
- Ubuntu: Logs are in `/var/log/tomcat8/`
- Ubuntu: Wars are in `/var/lib/tomcat8/webapps`
- Mac Homebrew: `catalina {run|stop|start|restart}`
- Mac Homebrew: ROOT is in `/usr/local/Cellar/tomcat/{{version}}/libexec/webapps/ROOT`
- Mac Homebrew: Logs are in `/usr/local/Cellar/tomcat/{{version}}/libexec/logs`

- Creating bin/rails: `rake rails:update:bin`

<sup>1</sup> While Rukh runs on Windows with Tomcat, a JRuby bug (`TCPSocket.open('ipaddrss', 25)`) prevented email delivery using SMTP. This bug may have been fixed since tested. 