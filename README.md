# Podman rootless mode in kubernetes or openshift

- How to run podman in kubernetes or openshift ?
- How to build a container Image in a container ?
- How to build a container Image in a jenkins job ?

references :

- https://docs.openshift.com/pipelines/1.14/secure/unprivileged-building-of-container-images-using-buildah.html

## Create the container image with Podman to run Podman in rootless mode

```bash
$ podman build -f Containerfile -t podman-builder .
```

## Create a namespace in OpenShift

```bash
$ oc create project podman
```

## Create service account with minimal Security Context Constraint (SCC) 

```bash
$ oc create -f podman-sa.yaml
```

## Copy the container image in k8s/openshift

```bash
$ skopeo copy containers-storage:localhost/podman-builder:latest docker://image-registry.apps.xxxxx/podman/podman-builder:latest
```

## Create an deployment to test the image

```bash
$ oc create -f deployment.yaml
```

## To run this image with jenkins / openshift(k8s)

```code
pipeline{
  agent {
    kubernetes {
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            label: jenkins-podman-builder
        spec:
          serviceAccountName: podman-scc-sa
          containers:
          - name: podman-builder
            image: image-registry.openshift-image-registry.svc:5000/podman/podman-builder:latest
            securityContext:
              capabilities:
                add:
                - "SETUID"
                - "SETGID"
            command:
            - /bin/sh
            - '-c'
            - /entrypoint.sh cat
            tty: true
            env:
              - name: HOME
                value: /home/jenkins/agent
      '''
    }
  }

  stages{
    stage('Build Container Image') {
      steps {
        container('podman-builder'){
          sh 'podman info'
          sh"""
          echo "FROM registry.access.redhat.com/ubi9/ubi-minimal\nRUN echo ok" > Containerfile
          """
          sh 'podman build -f Containerfile -t firstImage'
          sh 'podman images'
        }
      }
    }
  } // stages
} // pipeline
```
