#!/bin/bash

# Get the new pod name first
kubectl get pods -n isupod

# Replace POD_NAME with your actual pod name in the commands below
POD_NAME="podxs-744d46dddb-nztzx"

echo "=== 1. CHECK POD STARTUP LOGS ==="
kubectl logs $POD_NAME -n isupod

echo -e "\n=== 2. CHECK SERVICE STATUS INSIDE POD ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "ps aux | grep -E '(xrdp|code-server)'"

echo -e "\n=== 3. CHECK LISTENING PORTS ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "ss -tlnp | grep -E '(3389|8080)' || netstat -tlnp | grep -E '(3389|8080)'"

echo -e "\n=== 4. TEST LOCAL CONNECTIVITY INSIDE POD ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "timeout 3 bash -c 'echo > /dev/tcp/127.0.0.1/3389' && echo 'XRDP responding locally' || echo 'XRDP NOT responding locally'"

echo -e "\n=== 5. CHECK IPTABLES RULES ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "iptables -L INPUT -n | head -10"

echo -e "\n=== 6. CHECK XRDP LOGS ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "cat /var/log/xrdp.log | tail -20"

echo -e "\n=== 7. CHECK XRDP-SESMAN LOGS ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "cat /var/log/xrdp-sesman.log | tail -20"

echo -e "\n=== 8. CHECK USER SESSION FILES ==="
kubectl exec -it $POD_NAME -n isupod -- bash -c "ls -la /home/developer/.x*"

echo -e "\n=== 9. TEST CONNECTIVITY FROM NODE TO POD ==="
POD_IP=$(kubectl get pod $POD_NAME -n isupod -o jsonpath='{.status.podIP}')
echo "Pod IP: $POD_IP"
timeout 3 bash -c "echo > /dev/tcp/$POD_IP/3389" && echo "Pod RDP reachable from node" || echo "Pod RDP NOT reachable from node"

echo -e "\n=== 10. TEST NODEPORT FROM NODE ==="
timeout 3 bash -c "echo > /dev/tcp/127.0.0.1/30157" && echo "NodePort RDP working" || echo "NodePort RDP NOT working"

echo -e "\n=== 11. CHECK SERVICE ENDPOINTS ==="
kubectl get endpoints -n isupod podxs-service

echo -e "\n=== 12. CHECK SERVICE DETAILS ==="
kubectl describe svc podxs-service -n isupod
