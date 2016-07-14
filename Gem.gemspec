$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

Gem::Specification.new do |spec|
    spec.version = '0.0.2'
    spec.files = %W(Rakefile Gemfile README.md LICENSE) + Dir['lib/**/*']
    spec.name = 'jekyll-ts'
    spec.summary = 'Typescript compilation for Jekyll'
    spec.authors = ['Matt Sheehan', 'Patrick Lavigne']
    spec.require_paths = ['lib']

    spec.add_runtime_dependency('jekyll', '>= 3.0', '~> 3.1')
end
