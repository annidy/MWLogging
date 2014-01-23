// We need all the log functions visible so we set this to DEBUG
 
#import "MWLogging.h"
#define MAX_LOG_SIZE 1024*1024
static void AddLogFile(NSString *fname);
static void AddStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
	#if SUPPORT_LOG_FILE
		AddLogFile([NSTemporaryDirectory() stringByAppendingPathComponent:@"MyLogFile.log"]);
	#endif
	});
}
 
void _MWLog(int LEVEL, NSString *format, ...)
{
	AddStderrOnce();
	va_list args;
	va_start(args, format);
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
	asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]);
#if !__has_feature(objc_arc)
	[message release];
#endif
	va_end(args);
}

static void AddLogFile(NSString *fname)
{
	int result = 1;
	int fd = -1;
	NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:fname error:NULL];
	unsigned long long fsize = [attrs fileSize];
	if (fsize > MAX_LOG_SIZE) {
		fd = open([fname fileSystemRepresentation], (O_RDWR|O_CREAT|O_TRUNC), (S_IRWXU|S_IRWXG|S_IRWXO));
	} else {
		fd = open([fname fileSystemRepresentation], (O_RDWR|O_CREAT|O_APPEND), (S_IRWXU|S_IRWXG|S_IRWXO));		
	}
	if (fd != -1) {
		result = asl_add_log_file(NULL, fd);
	}
}