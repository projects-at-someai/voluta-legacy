workspace 'VTD v2.0'

project 'VTD Library v2.0/VTD Library v2.0.xcodeproj'
project 'LRF/LRF.xcodeproj'
project 'TRF/TRF.xcodeproj'
project 'PRF/PRF.xcodeproj'
project 'MRF/MRF.xcodeproj'
project 'CRF/CRF.xcodeproj'
project 'ORF/ORF.xcodeproj'
project 'BBRF/BBRF.xcodeproj'
project 'VTD VIP Registration/VTD VIP Registration.xcodeproj'
project 'VTD VIP Registration v2/VTD VIP Registration v2.xcodeproj'

def cloud_services_pods
    pod 'OneDriveSDK'
    #pod 'Dropbox-iOS-SDK'
    #pod 'GoogleAPIClient/Drive'
    pod 'ObjectiveDropboxOfficial'
    #pod 'GTMOAuth2'
    pod 'GoogleAPIClientForREST/Drive'
    pod 'GTMAppAuth'
    pod 'AppAuth'
    pod 'GoogleSignIn'
    #pod 'box-ios-sdk'
end

def shared_pods
	pod 'SSZipArchive', '~>2.4.3'
	
	#note: RNCryptor 3.0.1 is used because it is the last ver in Obj-C
	pod 'RNCryptor', '~>3.0.1'
	pod 'RMStore'
	pod 'RMStore/KeychainPersistence'
	pod 'MMSpreadsheetView'
	pod 'IAPHelper'
	#pod 'SQLCipher'
	pod 'NSString-Hashes'
	
	#source 'https://github.com/mentalfaculty/Specs.git'
	#source 'https://github.com/CocoaPods/Specs.git'
	#pod "Ensembles", "~> 2.0"
	#pod "Ensembles/Core", "~> 2.0"
	#pod "Ensembles/CloudKit"
	#pod 'tidy-html5'
	#pod 'GoogleSignIn'
		
end

def app_pods

	pod 'Fabric'
	pod 'Crashlytics'
    	pod 'Firebase/Core'
    
end

target 'VTD Library v2.0' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    pod 'OpenSSL-Universal'
    project 'VTD Library v2.0/VTD Library v2.0.xcodeproj'
end

target 'LRF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    app_pods
    project 'LRF/LRF.xcodeproj'
end

target 'TRF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
	app_pods
    project 'TRF/TRF.xcodeproj'
end

target 'PRF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    app_pods
    project 'PRF/PRF.xcodeproj'
end

target 'MRF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    app_pods
    project 'MRF/MRF.xcodeproj'
end

target 'ORF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    app_pods
    project 'ORF/ORF.xcodeproj'
end

target 'CRF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    app_pods
    project 'CRF/CRF.xcodeproj'
end

target 'BBRF' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    app_pods
    project 'BBRF/BBRF.xcodeproj'
end

target 'VTD VIP Registration' do
    platform :ios, '12.0'
    cloud_services_pods
    shared_pods
    project 'VTD VIP Registration/VTD VIP Registration.xcodeproj'
end

# target 'VTD VIP Registration v2' do
#     platform :ios, '12.0'
#     pod 'NSString-Hashes'
#     project 'VTD VIP Registration v2/VTD VIP Registration v2.xcodeproj'
# end
