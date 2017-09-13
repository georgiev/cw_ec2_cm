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
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = %w(cw-ec2-cm-install cw-ec2-cm-uninstall)
  spec.require_paths = ["lib"]

  spec.add_dependency 'whenever', '~> 0.9.7'

  spec.add_development_dependency "bundler", "~> 1.14"
end
