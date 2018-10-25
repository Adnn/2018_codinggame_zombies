from conans import ConanFile, CMake, tools


class ZombiesConan(ConanFile):
    name = "zombies"
    license = "The Unlicense"
    url = "https://github.com/Adnn/2018_codinggame_zombies"
    description = "Coding game 2018"
    settings = "cppstd", "os", "compiler", "build_type", "arch"
    options = {
        "shared": [True, False],
        "verbosebuild": [True, False],
        "buildtests": [True, False],
    }
    requires = (("boost/1.68.0@conan/stable"),
                ("libcurl/7.61.0@ag/stable"),
               )
    default_options = ("shared=False",
                       "verbosebuild=False",
                       "buildtests=False",
                      )
    build_requires = "cmake_installer/[>3.9]@conan/stable"
    build_policy = "missing"
    generators = "cmake_paths"

    scm = {
        "type": "git",
        "subfolder": "cloned_repo",
        "url": "https://github.com/Adnn/2018_codinggame_zombies.git",
        "revision": "auto",
        "submodule": "recursive",
    }

    def build(self):
        definitions = {
            # We disable the 'build by Conan' detection,
            # in order *not* to use Conan cmake generator file.
            #"AG_BUILD_BY_CONAN": True,

            "OPTION_VERBOSE_ADD_SUBDIR": self.options.verbosebuild,
            "BUILD_Tests": self.options.buildtests,
        }

        cmake = CMake(self)
        cmake.configure(source_folder="cloned_repo", defs=definitions)
        cmake.build()
        cmake.install()

    def package(self):
        # Done by the install step in build()
        # see: https://docs.conan.io/en/latest/howtos/cmake_install.html
        pass

    def package_info(self):
        self.cpp_info.libs = tools.collect_libs(self)

    def deploy(self):
        pass
