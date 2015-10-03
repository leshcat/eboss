include_recipe "eboss::jboss_standalone"

service 'jboss' do
	action :restart
end
