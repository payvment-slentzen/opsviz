%w[
  fog
  unf
  right_aws
  array_stats
  rest-client
].each do |package|
  gem_package package do
    action :install
  end
end

sensu_check "check-graphite-cache" do
  command "graphite.rb -h #{node[:graphite][:host]}:8081 -t carbon.agents.*.cache.size -a 1000,5000 -p 10minutes -g"
  handlers node[:bb_monitor][:sensu][:default_check_handlers]
  subscribers ["dashboard"]
  interval 300
  additional(:occurrences => 2)
end

sensu_check "check-es-heap" do
  command "check-es-heap.rb -h #{node[:kibana][:elasticsearch_server]}"
  handlers node[:bb_monitor][:sensu][:default_check_handlers]
  subscribers ["dashboard"]
  interval 300
  additional(:occurrences => 2)
end

sensu_check "check-es-cluster-status" do
  command "check-es-cluster-status.rb -h #{node[:kibana][:elasticsearch_server]}"
  handlers node[:bb_monitor][:sensu][:default_check_handlers]
  subscribers ["dashboard"]
  interval 300
  additional(:occurrences => 2)
end

sensu_check "check-es-file-descriptors" do
  command "check-es-file-descriptors.rb -h #{node[:kibana][:elasticsearch_server]}"
  handlers node[:bb_monitor][:sensu][:default_check_handlers]
  subscribers ["dashboard"]
  interval 300
  additional(:occurrences => 2)
end

stack_name = node[:opsworks][:stack][:name].downcase.gsub(' ','_')
# Metrics
sensu_check "metric-cluster-elasticsearch" do
  type "metric"
  command "es-cluster-metrics.rb -h #{node[:kibana][:elasticsearch_server]} -s stats.#{stack_name}.elasticsearch.cluster"
  handlers node[:bb_monitor][:sensu][:default_metric_handlers]
  subscribers ["dashboard"]
  interval 60
end

sensu_check "metric-node-elasticsearch" do
  type "metric"
  command "es-node-metrics.rb -h #{node[:kibana][:elasticsearch_server]} -s stats.#{stack_name}.elasticsearch"
  handlers node[:bb_monitor][:sensu][:default_metric_handlers]
  subscribers ["dashboard"]
  interval 60
end
