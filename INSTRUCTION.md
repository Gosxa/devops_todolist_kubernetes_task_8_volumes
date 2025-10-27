# Validation instructions

Follow these steps to validate the app and the two mounted volumes. Replace placeholders (<...>) with your actual names/paths and run commands from a machine with kubectl access to the cluster.

1) Verify the app is running
- List pods and check Ready/STATUS:
    ```bash
    kubectl get pods -n <namespace>
    ```
    Expect pod(s) in `Running` state and READY column shows containers ready.

- Wait for deployment to complete (if using a Deployment):
    ```bash
    kubectl rollout status deployment/<deployment-name> -n <namespace>
    ```

- Quick functional check (if the app serves HTTP):
    - Port-forward to local port and curl:
        ```bash
        kubectl port-forward svc/<service-name> 8080:80 -n <namespace> &
        curl -sS -o /dev/null -w "%{http_code}\n" http://localhost:8080/health
        ```
        Expect HTTP 200 (or your app's expected status).

- Inspect logs for startup errors:
    ```bash
    kubectl logs -f <pod-name> -c <container-name> -n <namespace>
    ```

2) Verify ConfigMap data is mounted as files (and in the expected order)
- Inspect the ConfigMap keys and expected filenames:
    ```bash
    kubectl get configmap <configmap-name> -n <namespace> -o yaml
    ```
    Note the keys and their expected mapping to filenames (if you used `items` to rename).

- List files in the mount directory inside the pod:
    ```bash
    kubectl exec -n <namespace> <pod-name> -- ls -1 <mount-path-for-configmap>
    ```
    Expect the filenames that correspond to ConfigMap keys (or the names you declared in `items`), in the order you expect (e.g., `00-*, 10-*` if you used numeric prefixes).

- Confirm file contents match the ConfigMap:
    ```bash
    kubectl exec -n <namespace> <pod-name> -- sh -c 'for f in <mount-path-for-configmap>/*; do echo "---- $f"; cat "$f"; done'
    ```
    Each file's content should match the corresponding value from `kubectl get configmap <name> -o yaml`.

3) Verify Secret data is mounted as a file
- List files in the secret mount directory:
    ```bash
    kubectl exec -n <namespace> <pod-name> -- ls -1 <mount-path-for-secret>
    ```
    You should see the secret key names (or filenames you specified via `items`).

- Inspect the secret file contents (it will be decoded by the volume mount):
    ```bash
    kubectl exec -n <namespace> <pod-name> -- cat <mount-path-for-secret>/<secret-filename>
    ```
    The output should be the plaintext secret value (compare with `kubectl get secret <secret-name> -n <namespace> -o yaml` — the `data:` values there are base64-encoded).

- Optional: check file permissions if required by your application:
    ```bash
    kubectl exec -n <namespace> <pod-name> -- ls -l <mount-path-for-secret>
    ```

Notes and troubleshooting
- If files are missing or names differ, check Pod spec `volumes` and container `volumeMounts.items` for `configMap`/`secret` entries and any `items` mappings or `subPath` usage.
- If contents are incorrect, re-check the ConfigMap/Secret resource contents and that the Pod was restarted after changes (ConfigMap/Secret volume updates require a pod restart to take effect unless using projected resources with automount behavior).
- Use `kubectl describe pod <pod>` to see mount-related events and errors.

Replace placeholders: <namespace>, <pod-name>, <deployment-name>, <service-name>, <configmap-name>, <secret-name>, <mount-path-for-configmap>, <mount-path-for-secret>, <secret-filename>.