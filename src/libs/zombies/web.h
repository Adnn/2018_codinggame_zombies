#pragma once

#include <string>


namespace cg
{

class Transfer
{
    struct InstanceData;

public:
    Transfer();
    // Usual opaque ptr requirement to define in cpp file
    ~Transfer();

    std::string get(std::string aUrl);

private:
    struct Initializer
    {
        Initializer();
        ~Initializer();
    };
    static Initializer gInitialization;

    std::unique_ptr<InstanceData> mData;
};

} // namespace cg
