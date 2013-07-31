if RUBY_VERSION >= '2.0'
  activerecord_versions = ['~> 3.2.13', '~> 4.0.0']
else
  activerecord_versions = ['~> 3.1.12', '~> 3.2.13', '~> 4.0.0']
end

activerecord_versions.each do |activerecord_version|
  appraise "activerecord_#{activerecord_version.slice(/\d+\.\d+/)}" do
    gem 'activerecord', activerecord_version
  end
end
