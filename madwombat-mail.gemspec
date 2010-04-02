# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{madwombat-mail}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Don Werve"]
  s.date = %q{2010-04-02}
  s.description = %q{Mail parser, builder, and delivererer.}
  s.email = %q{don@madwombat.com}
  s.files = ["Manifest", "Rakefile", "lib/java/mail.jar", "lib/mail/message.rb", "lib/mail/message/body_part.rb", "lib/mail/message/builder.rb", "lib/mail/message/builder/body_part.rb", "lib/mail/message/builder/multipart.rb", "lib/mail/message/multipart.rb", "madwombat-mail.gemspec"]
  s.homepage = %q{https://sydney/git/?p=madwombat-mail.git}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Madwombat-mail"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{madwombat-mail}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A Javamail-backed mail handler for JRuby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
