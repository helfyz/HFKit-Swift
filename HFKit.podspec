Pod::Spec.new do |s|

    s.name                  = 'HFKit'
    s.version               = '0.0.1'
    s.summary               = 'HFKit-Swift'
    s.homepage              = 'https://github.com/helfyz'
    s.ios.deployment_target = '11.0'
    s.license               = { :type => 'MIT', :file => 'LICENSE' }
    s.author                = { 'helfy' => '562812743@qq.com' }
    s.social_media_url      = 'https://github.com/helfyz'
    s.source                = { :git => 'https://github.com/helfyz/HFKit-Swift.git', :tag => s.version }
    
    s.subspec 'Extensions' do |extensions|
        extensions.source_files = 'LibClasses/Extensions/**/*'
           
    end

    s.subspec 'VideoLoader' do |videoLoader|
        videoLoader.source_files = 'LibClasses/VideoLoader/**/*'
          videoLoader.dependency 'HFKit/Extensions'
    end
  
    s.subspec 'HFLinkageViewController' do |linkageViewController|
        linkageViewController.source_files = 'LibClasses/HFLinkageViewController/**/*'
    end
    
    s.subspec 'ListViewManager' do |listViewManager|
        listViewManager.source_files = 'LibClasses/ListViewManager/**/*'
        listViewManager.dependency 'HFKit/Extensions'
    end
    
    s.subspec 'HFLogger' do |logger|
        logger.source_files = 'LibClasses/HFLogger/**/*'
              logger.dependency 'HFKit/ListViewManager'
    end
  
   s.requires_arc = true
end

