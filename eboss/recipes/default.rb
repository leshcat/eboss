#
# Cookbook Name:: eboss
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

include_recipe 'java::default'
include_recipe 'zip::default'
include_recipe 'eboss::jboss_standalone'

