#include "web.h"

#include <curl/curl.h>

#include <sstream>


using namespace cg;

#define CHECK_CURL(x, msg) if( (x) != CURLE_OK) {throw std::runtime_error(std::string("[curl]") + (msg));}


size_t writeToStreamCallback(char *ptr, size_t size, size_t nmemb, void *userdata)
{
    std::stringstream &output = *static_cast<std::stringstream *>(userdata);
    output.write(ptr, size*nmemb);
    if (output) // The last IO operation was successful
    {
        return size*nmemb;
    }
    return 0;   // This signals an error condition, except if there were actually no byte to write
                // But is this an issue if the IO failed on 0 byte to write?
}


Transfer::Initializer::Initializer()
{
    CHECK_CURL(curl_global_init(CURL_GLOBAL_ALL), "Unable to global init");
}

Transfer::Initializer::~Initializer()
{
    curl_global_cleanup();
}


struct Transfer::InstanceData
{
    InstanceData();

    CURL *handle;
};

Transfer::InstanceData::InstanceData() :
    handle(curl_easy_init())
{
    if (handle == nullptr)
    {
        throw std::runtime_error("Cannot initialize curl handle");
    }
}

Transfer::Transfer() :
        mData(std::make_unique<InstanceData>())
{}

Transfer::~Transfer()
{}

std::string Transfer::get(std::string aUrl)
{
     CHECK_CURL(curl_easy_setopt(mData->handle, CURLOPT_URL, aUrl.c_str()), "Unable to set url");

     CHECK_CURL(curl_easy_setopt(mData->handle, CURLOPT_WRITEFUNCTION, &writeToStreamCallback),
                "Unable to set write func");

     std::stringstream oss;
     CHECK_CURL(curl_easy_setopt(mData->handle, CURLOPT_WRITEDATA, &oss),
                "Unable to set stringstream");

     CHECK_CURL(curl_easy_perform(mData->handle), "Unable to perform transfer");

     return oss.str();
}
