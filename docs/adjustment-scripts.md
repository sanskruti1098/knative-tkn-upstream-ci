# Add adjustment script

adjust.sh script is used to make source code changes during test runs. 

### Add support for new jobs in `setup-environment.sh`

1. Create a folder in `adjust/` with component name and version and add `adjust.sh` and other required files.
    Example: For job `client` `release-1.2`, directory will look something like

    ```
    adjust/
    │   README.md
    └─── client
    │   │   
    │   └─── release-1.2
    │       │   overlay.yaml
    │       │   adjust.sh
    │       │   ...
    │   
    └───eventing
    │   │  
    │   └─── release-1.2
    │   |   │   overlay.yaml
    │   |   │   adjust.sh
    │   |   │   ...
    │   │  
    │   └─── main
    │       │   overlay.yaml
    │       │   adjust.sh
    │       │   ...
    ```
    
2. Add/update `if` condition in `setup-environment.sh` for new job

    ```bash
    elif [ ${JOB} == "client-release-1.2" ]
        scp ${SSH_ARGS} ${SSH_USER}@${SSH_HOST}:${BASE_DIR}/adjust/client/release-1.2/* /tmp/
    fi
    ```
