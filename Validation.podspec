Pod::Spec.new do |s|
    s.name             = "Validation"
    s.version          = "1.0.0"
    s.summary          = "正则表达式"
    s.description      = <<-DESC
    Regex
    DESC
    s.homepage         = "https://github.com/Z-JaDe"
    s.license          = 'MIT'
    s.author           = { "ZJaDe" => "zjade@outlook.com" }
    s.source           = { :git => "git@github.com:Z-JaDe/Validation.git", :tag => s.version.to_s }
    
    s.requires_arc          = true
    
    s.ios.deployment_target = '13.0'
    s.swift_versions        = '5.0','5.1','5.2','5.3'
    s.frameworks            = "Foundation"

    s.source_files          = "Sources/**/*.{swift}"

end
