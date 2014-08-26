Pod::Spec.new do |s|
    s.name      = 'MQPasscodeViewController'
    s.version   = '1.0.0'
    s.summary   = 'A beautiful iOS 7 style passcode view controller for iPhone and iPad.' \
                  'Can be presented as a modal or just animated/transitions above your ' \
                  'current navigation controller stack.'

    s.homepage  = 'https://github.com/marqeta/mqpasscodeviewcontroller'

    s.source    = { :git => 'https://github.com/marqeta/mqpasscodeviewcontroller.git',
                    :tag => s.version.to_s }

    # Platform setup
    s.platform  = :ios, '7.0'
    s.requires_arc = true

    # Preserve the layout of headers in the Code directory
    s.header_mappings_dir = 'MQPasscodeController'

    # Subspecs
    s.subspec 'MQPasscodeController' do |ss|
        ss.source_files = 'MQPasscodeController/*.{h,m}'
    end

end
