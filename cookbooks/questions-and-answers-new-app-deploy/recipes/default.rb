#
# Cookbook Name:: questions-and-answers-new-app-deploy
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# Stop and delete the default site

include_recipe 'questions-and-answers-new-app-deploy::setup_iis'

include_recipe 'questions-and-answers-new-app-deploy::deploy_application'

include_recipe 'questions-and-answers-new-app-deploy::database'

include_recipe 'questions-and-answers-new-app-deploy::customize_application'
