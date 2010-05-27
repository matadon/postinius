# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{postinius}
  s.version = "0.1.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Don Werve"]
  s.date = %q{2010-05-26}
  s.description = %q{Mail parser, builder, and delivererer.}
  s.email = %q{don@madwombat.com}
  s.files = ["Manifest", "Rakefile", "lib/java/mail.jar", "lib/postinius.rb", "lib/postinius/address.rb", "lib/postinius/deliverator.rb", "lib/postinius/message.rb", "lib/postinius/message/body_part.rb", "lib/postinius/message/builder.rb", "lib/postinius/message/builder/body_part.rb", "lib/postinius/message/builder/multipart.rb", "lib/postinius/message/multipart.rb", "lib/postinius/mime_type.rb", "spec/address.rb", "spec/build.rb", "spec/deliverator.rb", "spec/message.rb", "spec/mime_type.rb", "spec/parse.rb", "test/data/csstooltips.zip", "test/data/forwarded-multipart-mime-message.email", "test/data/japanese-body.email", "test/data/japanese-recipient.email", "test/data/japanese-sender.email", "test/data/japanese-subject.email", "test/data/message-to-different-address.email", "test/data/mime-multipart-with-attachments.email", "test/data/mime-multipart.email", "test/data/multipart-mime-message-in-japanese.email", "test/data/multipart-mime-message-with-attachment.email", "test/data/multipart-mime-message.email", "test/data/multipart-mime-with-text-body.email", "test/data/simple-smtp-message.email", "postinius.gemspec"]
  s.homepage = %q{https://sydney/git/?p=postinius.git}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Postinius"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{postinius}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Javamail-backed mail handler for JRuby.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
