terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.33.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.3.2"
    }

  }
}

variable "gcp_project" {
  type        = string
  description = "GCP Project."
}


variable "gcp_zone" {
  type        = string
  description = "GCP Zone."
}

resource "google_compute_instance" "lamp-1-vm" {
  project      = "${var.gcp_project}"
  name         = "lamp-1-vm"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  #  zone         = "us-west1-b"
  zone         = "${var.gcp_zone}"
  machine_type = "n1-standard-2"

  network_interface {
    network = "default"
  }

  tags = ["http"]
  #  metadata_startup_script = "echo hi > /test.txt"
  metadata_startup_script = <<SCRIPT
    sudo service apache2 restart
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    sudo apt-get update
    sudo apt-get install apache2 php7.0
    SCRIPT
}

resource "google_monitoring_uptime_check_config" "http" {
  display_name = "Lamp Uptime Check, then click Next"
  period       = "60s"
  timeout      = "60s"

  http_check {
    path = ""
  }

  #  http_check {
  #    port = "8010"
  #    request_method = "POST"
  #    content_type = "URL_ENCODED"
  #    body = "Zm9vJTI1M0RiYXI="
  #  }

  monitored_resource {
    type = "gce_instance"
    labels = {
      project_id   = "${var.gcp_project}"
      instance_id  = google_compute_instance.lamp-1-vm.instance_id
      zone         = "${var.gcp_zone}"
    }
  }

  #  checker_type = "STATIC_IP_CHECKERS"
}

resource "google_monitoring_notification_channel" "basic_notify" {
  display_name = "notify_jason"
  type         = "email"
  labels = {
    email_address = "chunchieh.chuang@gmail.com"
  }
}

resource "google_monitoring_alert_policy" "alert_policy" {
  display_name = "Inbound Traffic Alert"

  #  Network traffic
  #  Set the Threshold position to Above threshold, Threshold value to 500 and Advanced Options > Retest window to 1 min. Click Next.
  #  oClick on Notification Channels again, then click on the Refresh icon to get the display name you mentioned in the previous step.
  #Click on Notification Channels again if necessary, select your Display name and click OK.
  #
  #
  combiner     = "OR"
  conditions {
    display_name = "testcondition"
    condition_threshold {
      filter     = "metric.type=\"agent.googleapis.com/interface/traffic\""
      duration   = "500s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }
}

#
#Type CPU load (1m) in filter by resource and metric name and click on VM instance > Cpu.
# Select CPU load (1m) and click Apply. Leave all other fields at the default value. Refresh the tab to view the graph.
#Add the second chart
#Click + Add Chart and select Line option in Chart library.
#Name this chart Received Packets.
#Click on Resource & Metric dropdown. Disable the Show only active resources & metrics.
#Type Received packets in filter by resource and metric name and click on VM instance > Instance. Select Received packets and click Apply. Refresh the tab to view the graph.
#
#resource "google_monitoring_dashboard" "dashboard" {
#  dashboard_json = <<EOF
#  {
#  "displayName": "Grid Layout Example",
#  "gridLayout": {
#    "columns": "2",
#    "widgets": [
#      {
#        "title": "Widget 1",
#        "xyChart": {
#          "dataSets": [{
#            "timeSeriesQuery": {
#              "timeSeriesFilter": {
#                "filter": "metric.type=\"agent.googleapis.com/nginx/connections/accepted_count\"",
#                "aggregation": {
#                  "perSeriesAligner": "ALIGN_RATE"
#                }
#              },
#              "unitOverride": "1"
#            },
#            "plotType": "LINE"
#          }],
#          "timeshiftDuration": "0s",
#          "yAxis": {
#            "label": "y1Axis",
#            "scale": "LINEAR"
#          }
#        }
#      },
#      {
#        "text": {
#          "content": "Widget 2",
#          "format": "MARKDOWN"
#        }
#      }
#    ]
#  }
#}
#EOF
#}
#
