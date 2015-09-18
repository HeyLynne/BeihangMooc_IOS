//
//  MPMoviePlayerController+Subtitles.h
//  MPMoviePlayerControllerSubtitles
//
//
//
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMoviePlayerController (Subtitles)
@property (strong, nonatomic) NSString *subtitleLabel;

#pragma mark - Methods
- (void)openWithSRTString:(NSString *)srtString completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
- (void)openSRTFileAtPath:(NSString *)localFile completion:(void (^)(BOOL finished))success failure:(void (^)(NSError *error))failure;
- (void)showSubtitles;
- (void)hideSubtitles;

@end

