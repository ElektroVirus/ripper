# ripper

Docker image and script for ripping CDs for upload with whipper.

# Usage

Install Docker. Download rip.sh, customize it and configure whipper.conf, or just run

```
bash <(curl -fsSL https://raw.githubusercontent.com/wappuradio/ripper/master/rip.sh)
```

to build the container, configure your drive and rip the currently inserted cd to ~/music if everything goes smoothly. The first run might take up to an hour, the rest depends on the drive and cd.

It's also probably a good idea to be in the groups ```docker``` and ```optical``` before starting.
