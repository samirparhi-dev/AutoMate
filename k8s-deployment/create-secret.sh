kubectl create secret generic samir-private-ghcr-secret --from-literal=token="$github_Package_token" -n sharang-prod \ &&
kubectl apply -f /Users/samirparhi-dev/codeSpace/personal/AutoMate/k8s-deployment/sharang-deployment.yaml -n sharang-prod \ &&
k get secret -n sharang-prod
kubectl get secret samir-private-ghcr-secret -n sharang-prod -o jsonpath="{.data.token}" | base64 --decode
kubectl get secret samir-private-ghcr-secret -n sharang-prod -o jsonpath="{.data}" | base64 --decode

kubectl create secret docker-registry samir-private-ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=samirparhi-dev \
  --docker-password=$github_Package_token \
  --docker-email=samirparhi@gmail.com \
  -n sharang-prod

k delete secrets samir-private-ghcr-secret
k get po -n sharang-prod
k delete deployments.apps -n sharang-prod sharang
k describe po sharang-64c4495469-phpxn -n sharang-prod
