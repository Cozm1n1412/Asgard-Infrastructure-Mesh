# Infrastructure Incident Log & Resolution Archive - Project Asgard

### 1. POSIX Filesystem Permission Mismatch (Java IOException RWX)
* **Symptom:** Jenkins inbound agent crashed immediately on startup, failing to initialize the work directory `/home/jenkins/agent/remoting`.
* **Root Cause:** Host directory permissions belonged to `root:root` due to Docker daemon creating the bind mount automatically. The container process was running under an unprivileged `jenkins` user (UID 1000), restricting write access.
* **Resolution:** Synchronized file ownership on the host filesystem by executing `chown -R 1000:1000` to match the container execution runtime user.

### 2. DNS Underline Specification Violation (JVM URISyntaxException)
* **Symptom:** Agent connectivity halted with a fatal `java.net.URISyntaxException: Illegal character in hostname`.
* **Root Cause:** The Docker Compose service was named `jenkins_master`. While Docker allows underscores in service naming networks, the Java Virtual Machine (JVM) URI parser strictly enforces RFC 952 and RFC 1123 sub-domain naming conventions, which prohibit underscores.
* **Resolution:** Refactored the overall networking architecture and service names to eliminate underscores, standardizing the host reference to `jenkinsmaster`.

### 3. Missing Jenkins Core Dependencies (Groovy Option Compiling Error)
* **Symptom:** Pipeline compilation aborted instantly with `Invalid option type "timestamps"`.
* **Root Cause:** The declarative pipeline framework requested the `timestamps()` option block, which requires the third-party "Timestamper" plugin. Since the controller setup used a clean-slate core installation, the ecosystem lacked this visual layer.
* **Resolution:** Stripped the visualization wrapper from the `Jenkinsfile` options block to maintain cross-system compatibility with generic Jenkins clusters.

### 4. Host Docker Socket Isolation (Docker-out-of-Docker Lockout)
* **Symptom:** 'Terraform Init' and 'Plan' passed successfully, but 'Terraform Apply' failed instantly with a communication error.
* **Root Cause:** The containerized agent environment lacked a transport interface to talk to the host machine's execution engine daemon.
* **Resolution:** Implemented a Docker-out-of-Docker (DooD) pattern by bind-mounting the host's `/var/run/docker.sock` directly into the agent manifest.

### 5. Volatile UNIX Socket Access Control (Permission Denied on Socket)
* **Symptom:** Pipeline failed with `permission denied while trying to connect to the Docker daemon socket`.
* **Root Cause:** The host `/var/run/docker.sock` is owned by `root:docker`. At OS reboots or power loss, Arch Linux regenerates this file under `tmpfs` with default `660` permissions, locking out the agent.
* **Resolution:** Configured a persistent Systemd drop-in override (`ExecStartPost`) in `docker.service` on the host machine to automatically flag permissions to `666` at daemon startup.

### 6. Broken Image Build Context (Volume Path Desynchronization)
* **Symptom:** 'Terraform Apply' failed with `failed to read dockerfile: no such file or directory`.
* **Root Cause:** A minor character omission typo (`gugnir` instead of `gungnir`) inside the volume mapping arrays forced Docker to instantiate a blank root directory inside the agent instead of exposing the live application repository.
* **Resolution:** Standardized and aligned the volume array path syntax inside the root `docker-compose.yml` manifest to guarantee clean visibility.
