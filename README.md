### introduction

I created a basic terraform cicd pipeline.

Using google cloud resources, I created 2 service accounts, 1 compute 
nework, 1 subnetwork, 1 storage bucket and 1 storage bucket object using 
startup script, 2 VM instances using e2 micro machine type and 
us-central1-a as zone, firewalls allowing ssh and http, with protocol tcp 
and port 80, with source ranges 0.0.0.0/0, 1 unmanaged instance group with 
the 2 earlier created VM instances, 1 backend service with global address, 
forwarding rule with External Managed Load balancing scheme, http proxy, 
url map, and health check.
