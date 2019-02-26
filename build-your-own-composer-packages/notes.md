## Before talk
* Vagrant up
* Reset VM - `sudo salt-call state.sls reset`

## Slides
* Ask about composer experience

## Setup
* Open 192.168.37.37 in browser
* Gitea setup: Use sqlite, set domain to 192.168.37.37, application URL to http://192.168.37.37:3000/
* Unlock Jenkins
* Install recommended plugins and wait
* Show that Satis 404s for now

## Package
* Create 'left-pad' repo and clone
* Composer init (no packages yet), add autoload config snippet, dump autoload
* Create LeftPad class
* Composer require --dev phpunit (version 8, requires php 7.2), composer install, create test case
* Push to gitea

## Package job
* Jenkinsfile for package with native commands
* Create 'left-pad' Jenkins job
* Run first build - failure
* Use docker agent clause to run composer and php-cli images

## Satis job
* Create 'satis-config' repo and clone
* Create satis.json, note about secure-http
* Jenkinsfile for satis, use docker command (not docker agent), no cleanup tasks
* Create 'satis-config' Jenkins job
* Run build when package build succeeds

## Project
* Create repo locally
* Composer init
* Copy install instructions from satis webpage
* Composer require package
* Create simple script

## Job creator
* Install DSL plugin
* Create 'jenkins-config' repo and clone
* Create 'provision-jenkins' Jenkins job
* Remove all other jobs
* Run job, fails due to groovy security
* Untick Global security -> Enable job DSL script security (should have security another way, e.g. in git)
* Run job, show and run generated jobs
