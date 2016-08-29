# Medical Imaging Quiz

## Setup

First, install [Vagrant](http://www.vagrantup.com). 

After installation has completed, open a command window and type `vagrant`, just to be sure it installed successfully.
Navigate to where you want to clone this repository and do the following:

    git clone
    cd medimgquiz
    vagrant up     # This will take a little while
    vagrant ssh    # This may take a little while the first time.
    make dev       # This may also take a while the first time.
    make run
    
The webside can now be found on [http://localhost:12345](http://localhost:12345).

## Development

For further development, alter the code, add and commit new changes. To run:

    cd /path/to/medimgquiz
    vagrant ssh
    make run