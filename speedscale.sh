export PATH=$PATH:/var/lib/jenkins/.speedscale
SCENARIO_TAG=$(git rev-list --abbrev-commit --max-count=1 HEAD)-$(date +%s%N)

sed "s/COMMIT_HASH/${SCENARIO_TAG}/g" scenario.yaml | kubectl apply -f -
echo "Waiting for scenario report to be available"

for i in {1..20}; do
  echo "Checking for available report (attempt ${i})"
  echo 'Speedscale Status'
  echo $(speedctl report get ${SCENARIO_TAG})
  status=`$(speedctl report get ${SCENARIO_TAG} | jq -rc '.status' | tr '[[:upper:]]' '[[:lower:]]' || true)`

  case ${status} in
    "" | "initializing" | "in progress" | "running")
      echo "Report not ready, sleeping (status ${status})"
      sleep 30
      ;;

    "complete" | "missed goals" | "stopped" | "passed")
      echo "Report complete (status ${status})"
      kubectl get test-report ${SCENARIO_TAG} -o jsonpath='{.spec.junit}'  > report.xml
      events=$(speedctl report get ${SCENARIO_TAG} | jc -rc '.events' )
      if [[ "${events}" == "" ]]; then
        echo "Passed!"
        exit 0
      else
        echo "Failed!"
        exit 1
      fi
      ;;
  esac
done
