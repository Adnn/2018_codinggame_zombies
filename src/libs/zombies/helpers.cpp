#include "helpers.h"

#include <boost/filesystem.hpp>

namespace cg
{
    std::string getFood()
    {
        if (boost::filesystem::exists("/tmp/brains"))
        {
            return "brains"; 
        }
        else
        {
            return "just passing by";
        }
    }
} // namespace cg
