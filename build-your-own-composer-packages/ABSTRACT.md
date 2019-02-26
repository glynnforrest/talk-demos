# Build and host your own Composer packages

The Composer package manager has improved PHP development perhaps more than anything else in the last decade. Instead of copying code from project to project, we can now require specific packages with Composer. Packagist is a great public repository for these packages, but teams often need to keep their own internal packages private.

In this live-coding talk, we'll learn how to create a Composer package, host it on private infrastructure, and require it in a new project.

We'll build a brand new package from scratch; test it using Docker on the Jenkins CI server; host it internally using our own package repository, Satis; and finally, investigate Jenkins-ception - using Jenkins to provision itself.
