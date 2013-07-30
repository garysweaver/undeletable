['~> 4.0.0', '~> 3.2.13', '~> 3.1.12'].each do |activerecord_version|
  appraise "activerecord_#{activerecord_version.slice(/\d+\.\d+/)}" do
    gem 'activerecord', activerecord_version
  end
end
