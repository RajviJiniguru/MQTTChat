
Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "MQTTSDK"
s.requires_arc = true
s.summary = "This is Chat module using MQTT"
# 2
s.version = "1.0.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "RajviJiniguru" => "rajvi.turakhia@jini.guru" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = 'https://github.com/RajviJiniguru/'


# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/RajviJiniguru/MQTTChat.git", :tag => "1.0.0" }

# 7
s.framework = "UIKit"


# 8
s.source_files = "MQTTSDK/**/*.{swift}"

# 9
#s.resources = "MQTTSDK/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "5.0"

s.exclude_files = "Classes/Exclude"
end


