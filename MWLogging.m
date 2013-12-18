// We need all the log functions visible so we set this to DEBUG
 
#import "MWLogging.h"
 
static void AddStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
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