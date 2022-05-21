Release Notes
=============

2.9.2
---
- Fixed issue introduced in 2.9 when storing transformable properties
- The delegate methods used during merging for repairing issues would not properly capture default values in objects newly added in the repair. Now these defaults should be properly captured.
- When merging baselines, if the local baseline is new (ie just leeched), remote baselines will be given priority. In general, a remote baseline will be complete, where it is possible a local store may be incomplete due to a failed merge followed by a deleech. It is better to favor the remote baseline.
- The XCFramework target now builds for all platforms, including macOS, tvOS, and watchOS.
- Fix to header file of `CDECloudFileSystem.h` to make it work with the Swift Package Manager.
- Added better tests for transformable properties and repairing of failed merges.

2.9.1
---
- Reenabled Mac Catalyst in the IOS Module target

2.9
---
- Support for Xcode 12
- Support for Apple Silicon (arm64 on macOS)
- Added preliminary support for Swift Package Manager
- The UUID type is now supported in Core Data models
- Secure coding is now used for transformers internally
- Support for Dropbox 3.11.2
- Support for recent changes to CloudKit on watchOS
- Fixed some error handling and wrong completion block calling behavior
- Performance improvements around calculation of model hashes
- Correct nullability settings for certain initializers
- CDEZipCloudFileSystem now has a delegate that allows code to avoid zipping particular files
- An empty model version id will now not be considered valid in model version checks. Previously this was allowing models to pass when they shouldn't have

2.8
---
- Fixed errors due to removal of `CKSubscription` methods in iOS 14.
- More tolerant model checking. If model identifiers have been applied by the developer, matching identifiers will be considered from the same model version, regardless whether the entity hashes match. This was needed because Apple's hashing changed between OS releases for some specific models. If you use identifiers for your model versions, you can future proof yourself against such hashing changes.
- Changes to avoid new warnings from the compiler.
- Fixed issues with ZipArchive import in CocoaPods.
- Added deployment target for CloudKit in CocoaPods.
- Updates for Swift 5.
- Support for recent Dropbox SDK.
- Fixed bug with handling of one-to-one relationships on superentities.
- isLeeched was not always properly updated on some failures. It is now.
- Support for deleting files from a shared directory. Note that this does not prevent other devices reuploading the files. (No tombstones are used.)
- Removed `CKSubscription` code on watchOS.

2.7
---
- Support for keeping a folder of files in sync across devices.
- Fixes for Dropbox and Zip backends to work around some blocking of main thread.
- Improvements to the multipeer backend.
- Better handling of certain errors for CloudKit backend.

2.6.2
---
- Updated ZipArchive
- Added a `CDEMonitoredManagedObjectContextSaveChangesWillBeStoredNotification` notification
- Added priming for `+retrieveEnsembleIdentifiers...` method. Without this, the cached data might be out of date
- Fixes in baseline version checking and consolidation.
- Fixed some error handling in `CDECloudKitFileSystem`
- Better handle CloudKit limits in `-fetchRecordsAtPaths:...` method
- Respect batch size settings when adding global identifiers during initial import
- Fixed some ARC memory issues with error handling
- Improved error handling in Dropbox class
- Increased batch size for baseline consolidation to increase performance
- Improved prefetching during baseline consolidation

2.6.1
---
- Improvements to CloudKit sharing
- CloudKit shares that are automatically removed when last participant leaves are automatically recreated
- New `CDECloudKitFileSystem` delegate methods for when shares are being added and removed
- Support for new CloudKit subscriptions
- Changed version of Dropbox and RNCryptor
- More fixes for NSError problems with ARC and autorelease pools
- Fixes for macOS 10.13 and iOS 11

2.6
---
- Updates to accommodate changes in Dropbox SDK (v2)
- Batch uploads used to improve efficiency of Dropbox v2 backend, and reduce likelihood of errors
- Improvements to retry behavior in Dropbox v2 backend
- Fixed problems with Dropbox v2 backend when using the partitioning of data files option (non-default)
- Updated Idiomatic for macOS to use CloudKit and sync with the iOS version (when using CloudKit)

2.5.2
---
- Added watchOS framework target
- Updated Dropbox V2 SDK to version 3.0.x. This requires a few class name changes.
- Renamed the Dropbox (v2) subspec name for Cocoapods. It is now 'DropboxV2'
- Updated README for new Dropbox SDK
- Added long-polling for update notifications in Dropbox backend. Call `subscribeForRemoteFileChangeNotificationsWithCompletion:` to start the long polling, and implement the delegate method `dropboxCloudFileSystemDidDetectRemoteFileChanges:` to be informed when cloud files have been updated.
- Replaced SSZipArchive with official ZipArchive, which is supported by Cocoapods.
- Fixed a problem in the encrypted backend class when wrapping certain other backends (eg CloudKit)
- Added `cloudKitFileSystem:willSaveNewShare:` delegate method, to make it possible to configure a new share before it is added to the cloud

2.5.1
---
- Added support for private sharing with the `CDECloudKitFileSystem`. It allows a single persistent store to be shared between two or more iCloud users, using the new `CKShare` API. For more information, see `CDECloudKitFileSystem.h`.
- Added on-disk caching of CloudKit fetches. This dramatically speeds up the first merge after launch.
- Fixed a number of memory issues around `NSError` propagation, that arose due to `performBlock` Core Data methods now having an internal autorelease pool.
- Fixed a problem when removing ensemble data from the cloud using the CloudKit backend. It was not properly priming, to get the latest list of files for removal. This could leave files behind, which could interfere with any new leech by introducing old data.

2.5
---
- Added support for the Dropbox v2 API. The new class `CDEDropboxV2CloudFileSystem` has been introduced. It is compatible with the cloud files of the v1 API, but will require the user to login again.
- Introduced non-critical, informative errors (`nonCriticalErrorCodes` property). These do not cause a failure, but can be useful to the app. An example is when an unknown model is found in the cloud. This can be a good indication that the user should be encouraged to upgrade to the latest version.
- Simple Sync in Swift example is now in Swift 3.
- Fix for issues when using a non-standard root directory with the CloudKit backend.
- Fixes for various memory issues related to autoreleasing error arguments, which only arose in the latest OSes.
- The Ensembles Resources are now a dependency of the iOS static library, to ensure the bundle gets built.

2.4.2
---
- You can now set a root directory for Dropbox storage.
- Setting added to Dropbox class that can be used to avoid hitting 10000 file limit. It introduces subfolders to do this.
- Fixed issue with Dropbox when removing files could sometimes 'choke' the SDK. Now batched.
- Removed Dropbox Sync backend.
- Improved progress updates when exporting event files.
- Improved multipeer backend, with file-available notifications that can be used for more immediate syncing.
- Added a tvOS framework target.
- Fixed memory related crash due to overreleasing of an NSError in CDEEventIntegrator.

2.4.1
---
- Progress is now reported during downloading and uploading of files.
- Fixed a bug that could cause sync to fail, and even prevent new data being added, on devices 'left behind' by rebasing.
- Rebasing cleans up more data, and is more easily triggered by excessive data.
- Added target to build a universal module for iOS.
- Node backend will upload and download files in batches for better performance.
- Added `CDEMonitoredManagedObjectContextSaveChangesWereStoredNotification`, so you can know when Ensembles finishes storing data.
- Added check for `CKErrorUserDeletedZone` error, and recreate the zone.
- Updated file removal in CloudKit to explicitly remove each file. Were using automatic deletion, but that has a limit of 700 files.

2.4
---
- Updated settings to have bitcode generated in all release builds.
- Added support using a custom zone with CloudKit backend. This allows for atomic transactions, which may be more stable, and faster. Adopt the new initializer to use it.
- Introduced a new schema for CloudKit, and moved from query-based fetches to change-based fetches. Much faster, but only for the private database. Use the new initializer for this.
- Added batching for deletions with CloudKit. There is a limit of 400 items, and so for large deletions, it was possible to hit this limit.
- Changed Quality of Service for all CloudKit operations to user-initiated. Anything less can stall.
- Found a few places in CloudKit backend where the convenience methods were used. These no doubt default to the background QoS, so they have also been replaced to prevent stalls.
- Added CloudKit as an option in Idiomatic.
- Changed Quality of Service to user-initiated in other parts of the framework.
- Changed default size of batches for uploads and downloads with Dropbox Core to one. It seems to generate errors sometimes with multiple requests.
- Reduced excessive prefetching that could cause memory blowup for large stores.
- Made merges a lot faster when all new changes are from the local device.
- Changes for ordered relationships to avoid internal exceptions in Core Data.
- Added Simple Sync in Swift example.

2.3.3
---
- Added more missing Quality-of-Service settings in CloudKit backend.
- Renamed schemes.
- Added an iOS framework and module target.
- Better support for Swift with nullability and generics annotations.
- Fixed bug where a migration which adds a property could lead to lost data in rebasing or baseline consolidation.
- Fixed bug that could cause relationships to be left unset in models with inherited relationships.
- Updated RNCryptor for the encrypted backend.

2.3.2
---
- Changed the `storeURL` property name to `persistentStoreURL`. Will require updating in any calling code.
- Added `dismantle` method for `CDEPersistentStoreEnsemble`. If you want to stop using an ensemble (eg after it is deleeched), you can use this method to ensure it does not hang around causing side effects. The method stops the ensemble using data on the disk, and monitoring saves. It is also useful if you want to replace one ensemble object with another.
- Related to dismantling, there are now checks to make sure that when an ensemble is created, it does not share any disk data with another ensemble. Accidentally doing this could lead to unexpected bugs. This problem would typically arise if you tried to destroy one ensemble, and replace it with another.
- Added Quality of Service settings to all operation queues, to ensure they keep working even on mobile networks
- Set the Quality of Service of CloudKit operations. It was defaulting to 'background', causing stalling when off WiFi

2.3.1
---
- Fixed bug in `CDECloudKitFileSystem` that could cause files not to be removed, and accumlate, slowing sync and increasing cloud storage.
- Fixed the `CDESeedPolicyExcludeLocalData` option. Was not working after recent changes to dependency handling.
- Added `soundName` setting to CloudKit subscription to workaround a bug in which notifications don't fire on iOS 8.
- Changed Idiomatic for iOS to use the Dropbox Core API, rather than the Sync API. The Sync API is deprecated and will stop working in October, 2015.
- Added the new merge option `CDEMergeOptionsSuppressCloudFileDeposition`. This prevents uploading of data to the cloud. Can be used when responding to push notifications to prevent ping-ponging between devices. 
- Improved efficiency of Dropbox Core backend, by supporting simulataneous upload, download, and removal of multiple files.
- Fixed a retain cycle which would cause a `CDEPersistentStoreEnsemble` to linger after being released.
- Updated for Xcode 7, including Bitcode.
- SSZipArchive seems to have been deprecated and removed from the original GitHub repo. If you need it, you can use this version: https://github.com/mentalfaculty/SSZipArchive

2.3
---
- Missing files will not not cause a merge to fail. This solves the issue that a device with half uploaded files could go offline for a long time, leaving the remaining devices wedged and unable to sync. The other devices will now continue to sync, ignoring the half-complete files until all files have appeared.
- Fixed a threading bug that could affect ordered-relationships.
- There is now a property that allows compressed hashes to be used in the cloud data. This can save some storage. It is off by default.
- Added a test that generates a random sync history.
- Mention Swift in the README.


_Release Notes prior to 2.3 were not kept. The GitHub commit log can be used to see what changed in earlier releases._
