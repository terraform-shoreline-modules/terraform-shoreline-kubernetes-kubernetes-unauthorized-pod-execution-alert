resource "shoreline_notebook" "unauthorized_pod_execution_alert" {
  name       = "unauthorized_pod_execution_alert"
  data       = file("${path.module}/data/unauthorized_pod_execution_alert.json")
  depends_on = [shoreline_action.invoke_delete_pod_status,shoreline_action.invoke_change_access_control_policy]
}

resource "shoreline_file" "delete_pod_status" {
  name             = "delete_pod_status"
  input_file       = "${path.module}/data/delete_pod_status.sh"
  md5              = filemd5("${path.module}/data/delete_pod_status.sh")
  description      = "Immediately remove the unauthorized pod from the system."
  destination_path = "/tmp/delete_pod_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "change_access_control_policy" {
  name             = "change_access_control_policy"
  input_file       = "${path.module}/data/change_access_control_policy.sh"
  md5              = filemd5("${path.module}/data/change_access_control_policy.sh")
  description      = "Implement a stronger access control policy to prevent unauthorized pod creation in the future."
  destination_path = "/tmp/change_access_control_policy.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_delete_pod_status" {
  name        = "invoke_delete_pod_status"
  description = "Immediately remove the unauthorized pod from the system."
  command     = "`chmod +x /tmp/delete_pod_status.sh && /tmp/delete_pod_status.sh`"
  params      = ["POD_NAME"]
  file_deps   = ["delete_pod_status"]
  enabled     = true
  depends_on  = [shoreline_file.delete_pod_status]
}

resource "shoreline_action" "invoke_change_access_control_policy" {
  name        = "invoke_change_access_control_policy"
  description = "Implement a stronger access control policy to prevent unauthorized pod creation in the future."
  command     = "`chmod +x /tmp/change_access_control_policy.sh && /tmp/change_access_control_policy.sh`"
  params      = ["NAMESPACE","ROLE_BINDING_NAME","ROLE_NAME","SERVICE_ACCOUNT"]
  file_deps   = ["change_access_control_policy"]
  enabled     = true
  depends_on  = [shoreline_file.change_access_control_policy]
}

