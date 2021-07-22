Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "CustomStackView"
s.summary = "CustomStackView, a replacement for UITableview, right now we don't support reuseablity will be supported soon."
s.requires_arc = true

# 2
s.version = "1.0.3"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Neeraj Gupta" => "singla.nikk@gmail.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/nikusingla/CustomStackView"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/nikusingla/CustomStackView.git",
             :tag => "#{s.version}" }

# 7
s.framework = "UIKit"

# 8
s.source_files = "CustomStackView/**/*.{swift}"

# 9
s.resources = "CustomStackView/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5"

end
