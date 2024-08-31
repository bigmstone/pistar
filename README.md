# PiSTAR

Just some scripts to quickly set all my astrophotography software. Works on Pi's
version of Debian 12 (bullseye) -- compiles and runs smoothly on my RPi5.

# Includes

- Indi
  - By default compiles all 3rd party libs, but not all 3rd party drivers.
    The "biuld.sh" file will help you build any new drivers you need. Just
    run `build.sh <name of driver>` I.E. `build.sh indi-toupbase`.
- PHD2
- KStars
- StellerSolver

# Notes/Thoughts

With the RPi 5's PCI-E slot I can attach an M.2 drive and write all images to
it. Cron job then moves them off to my home server. I can run everything off the
PI and VNC in to work with KStars as needed.

These types of scripts tend to age poorly. They're not very resilient and rot
quickly. As package names change, dependencies evolve, etc. So YMMV if you
decide to use it. I will update it as I need to, but its not something I will
maintain regularly. Just on-demand when I'm provisioning something new.
