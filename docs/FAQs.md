# FAQs

## Q: How much disk space do I need?
A: The jumpstart download is ~500MB compressed (2GB uncompressed), the installation files are uncompressed and measure 6.5GB. Bare minimum virtual disk size would be around 20GB, but you'll find it hard to get any apps installed (like Xcode, which is at least 8GB compressed).

## Q: Does this work on DigitalOcean/ScaleWay/Azure/GCS?
A: If the cloud providers supports KVM as well as the necessary CPU instructions, yes.
   In some cases only certain tiers work on some providers as the CPUs need to be supported.
   
   For DigitalOcean, this means a `General Purpose` or `CPU Optimized` machine is required. `Ubuntu 19.04` or newer is recommended.