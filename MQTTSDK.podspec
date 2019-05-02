
Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '11.0'
s.name = "MQTTSDK"
s.requires_arc = true
s.summary = "MQTTSDK"
# 2
s.version = "1.0.3"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { 'RajviJiniguru' => 'raja.turakhia@jini.guru' }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = 'https://github.com/RajviJiniguru/'

s.ios.vendored_frameworks = 'Cardstream.framework'

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/RajviJiniguru/MQTTChat.git", :tag => "1.0.0" }



end


