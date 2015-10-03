include_recipe "eboss::jboss_standalone"

service 'jboss' do
	action :stop
end
