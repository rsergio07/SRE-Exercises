# Setting Up Alerts in Grafana for Latency and Errors Panels

Grafana alerts can notify you when a certain metric exceeds a defined threshold. Here’s how to create alerts for **Latency** and **Errors** in your Grafana dashboard.

## 1. Loki changes
Explicar que es y porque se usa
https://grafana.com/docs/loki/latest/alert/

```yaml
    ruler:
      storage:
        type: local
        local:
          directory: /loki/rules
      rule_path: /tmp/rules/fake/
      alertmanager_url: http://localhost:9093
      ring:
        kvstore:
          store: inmemory
      enable_api: true
```

## 2. Alert for Latency Panel

To create an alert for the **Latency** panel, follow these steps:

1. **Open the Latency Panel**: In your Grafana dashboard, go to the **Latency** panel.
2. **Edit the Panel**: Click on the panel title, select **Edit**.
3. **Go to the Alerts Tab**: Switch to the **Alerts** tab within the panel editor.
4. **Create a New Alert**:
   - **Click** on **Create Alert**.
   - **Define query and alert condition**: Set a condition that checks the latency over a certain threshold. For example:
     ```plaintext
     sum(rate(otel_collector_span_metrics_duration_milliseconds_bucket[5m])) by (span_name)
     ```
   - **Time Range**: Set the evaluation period to check latency, such as over the **last 10 minutes**.
5. **Expressions**:
   - **input**: Set `A` to use the expression above.
   - **is above**: 1.4, `1 400 miliseconds`.
6. **Set evaluation behavior**:
   - **folder**: CReate a folder.
   - **Evaluation group and interval**: create a group
6. **Configure labels and notifications**:
   - In the **Contact point** section, choose the notification channel to receive alerts, like **Slack**, **Email**, or **PagerDuty**. So far `grafana-default-email` is enough.
7. **Save Alert**: Save your changes to enable the alert.

This will send a notification when latency exceeds the defined threshold that represented with the red line in the image below
![grafana_alert](./images/grafana_test_alert.png)

## 3. Creating Additional Alerts Based on SLOs

Following the SLO definitions, create at least one alert for each SLO.

- **Endpoint Duration Below 1,400 Milliseconds**:
  ```plaintext
  sum(rate(otel_collector_span_metrics_duration_milliseconds_bucket[5m])) by (span_name)
  ```
  Set a threshold to trigger an alert if endpoint duration goes above 1,400 milliseconds.
- **Receive Bytes Below 250,000 Bytes**:
  ```plaintext
  sum(rate(container_network_receive_bytes_total[5m])) by (container_label_k8s_app)
  ```
  Set a threshold to trigger an alert if received bytes go below 250,000 bytes.
- **Availability with Fewer Than 5,500 Errors**:
  ```plaintext
  sum(count_over_time({service_name="unknown_service"} |= "err" [5m])) by (service_name)
  ```
Set a threshold to trigger an alert if the number of errors exceeds 5,500.

The idea is to receive an alert if any of the previous thresholds are exceeded.

In this [link](grafana.yaml), you will find all the required configurations to validate the results, which should generate something like this:

![alt text](images/grafana_test_alert.png)

Eventually, over time, the alerts will begin to trigger as arbitrary conditions have been implemented in the functions `goo`, `foo`, and `zoo` to simulate errors or service degradations.