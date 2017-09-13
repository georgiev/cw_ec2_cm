# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cw_ec2_cm/version'

Gem::Specification.new do |spec|
  spec.name          = "cw_ec2_cm"
  spec.version       = CwEc2Cm::VERSION
  spec.authors       = ["George Georgiev"]
  spec.email         = ["georgiev@heatbs.com"]

  spec.summary       = %q{AWS CloudWatch custom ec2 metrics}
  spec.description   = %q{Push instance memory and disk usage to EC2Custom CloudWatch namespace}
  spec.homepage      = "https://github.com/georgiev/cw_ec2_cm"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = %w(cw-ec2-cm-push cw-ec2-cm-install cw-ec2-cm-uninstall)
  spec.require_paths = ["lib"]

  spec.add_dependency 'whenever', '~> 0.9.7'

  spec.add_development_dependency "bundler", "~> 1.14"
end
