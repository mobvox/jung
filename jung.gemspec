# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "jung"
  s.version     = File.read('VERSION')
  s.authors     = ["arielpts", "danxexe"]
  s.email       = ["arielpts@me.com"]
  s.homepage    = "http://www.mobvox.com.br"
  s.summary     = "Eletronic message deliver proxy"
  s.description = "Have you ever wondered how it would be if there were an easy way to send your message to billions of people? The Jung’s collective unconscious will help in this arduous task!"

  # s.rubyforge_project = "admin_widgets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"

  s.add_runtime_dependency "gibbon"
  s.add_runtime_dependency "activesupport"
  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "rdoc"
  s.add_runtime_dependency "gsm_encoder"
end
