# Add adjustment script

adjust.sh script is used to make source code changes during test runs. 

### Add support for new jobs in `setup-environment.sh`

1. Create a folder in `adjust/` with component name and version and add `adjust.sh` and other required files.
    Example: For job `client` `release-1.17`, directory will look something like

    ```
    adjust/
    │   README.md
    └─── client
    │   │   
    │   └─── release-1.17
    │       │   overlay.yaml
    │       │   adjust.sh
    │       │   ...
    │   
    └───eventing
    │   │  
    │   └─── release-1.17
    │   |   │   overlay.yaml
    │   |   │   adjust.sh
    │   |   │   ...
    │   │  
    │   └─── main
    │       │   overlay.yaml
    │       │   adjust.sh
    │       │   ...
    ```