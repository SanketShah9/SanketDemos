

#ifndef Demo_WebService_h
#define Demo_WebService_h

#pragma mark - Web Service Section

//#production URL



//throwstream d3 URL
#if defined(THROWSTREAM_SANDBOX)
#define BASE_URL @"http://52.3.10.36/BL088.Web"
#else
#define BASE_URL @"https://service.throwstream.com/BL088.Web"
#endif

//home
#define Web_GET_STREAM_LIST_HOME BASE_URL@"/api/Stream/GetStreamsForHomePage?"
#define Web_POST_STREAM_REFRESH_HOME BASE_URL@"/api/Stream/RefreshStreamsForHomePage"


#endif
