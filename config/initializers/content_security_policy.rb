# frozen_string_literal: true

Rails.application.config.content_security_policy do |policy|
  policy.script_src :self
  policy.object_src :none
  policy.connect_src 'https://allsearch-api.princeton.edu', 'https://allsearch-api-staging.princeton.edu'
  policy.base_uri :none
  policy.frame_ancestors :none
end
