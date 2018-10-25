#include <zombies/helpers.h>
#include <zombies/web.h>

#include <iostream>


int main()
{
    std::cout << cg::getFood() << "!" << std::endl;

    cg::Transfer transfer;
    std::cout << "Also web: " << transfer.get("https://jsonplaceholder.typicode.com/todos/1") << std::endl;
    return 0;
}
