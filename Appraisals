# if add new minor version, change also in .travis.yml
['4.0.0', '3.2.14', '3.1.12'].each do |activerecord_version|
  appraise "activerecord_#{activerecord_version[0..2]}" do
    gem 'activerecord', activerecord_version
  end
end
