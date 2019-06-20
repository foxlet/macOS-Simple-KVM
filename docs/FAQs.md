# FAQs

## Q: Does this work on any CPU?
A: There is a minimum CPU requirement for macOS itself. Both Intel and AMD CPUs are supported, but the recommendations are Ivy Bridge (or later) Core and Xeon processors, or Ryzen and Threadripper processors.

## Q: How much disk space do I need?
A: The jumpstart download is ~500MB compressed (2GB uncompressed), the installation files are uncompressed and measure 6.5GB. Bare minimum virtual disk size would be around 20GB, but you'll find it hard to get any apps installed (like Xcode, which is at least 8GB compressed).

## Q: Does this work on DigitalOcean/ScaleWay/Azure/GCS?
A: If the cloud provider supports nested KVM as well as the necessary CPU instructions, yes.
   In some cases only certain tiers will work as the CPU need to be supported.
   
   For DigitalOcean, this means a `General Purpose` or `CPU Optimized` machine is required. `Ubuntu 19.04` or newer is recommended.
