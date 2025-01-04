<div align="center"><img width="200" src="https://avatars0.githubusercontent.com/u/49841676?s=200&v=4"></div>

# Jinja2CppMedium

A version of [jinja2cpp](https://github.com/jinja2cpp/Jinja2Cpp/) for inclusion in gd-webview.

### Requirements

#### linux

```bash
axel -a -n6 https://archives.boost.io/release/1.74.0/source/boost_1_74_0.tar.gz

tar -xzf boost_1_74_0.tar.gz
rm boost_1_74_0.tar.gz
cd boost_1_74_0

./bootstrap.sh
sudo ./b2 --with-atomic --with-system --with-filesystem variant=release link=static runtime-link=static cflags=-fPIC cxxflags=-fPIC install -a --prefix=/usr/local/boost/
```

#### windows

Download the installer [boost_1_74_0-msvc-14.2-64.exe](https://altushost-swe.dl.sourceforge.net/project/boost/boost-binaries/1.74.0/boost_1_74_0-msvc-14.2-64.exe?viasf=1)

it installs into `C:\local\boost_1_74_0`

### Improvements

- A more straightforward `CMakeLists.txt`
- Removed git submodules, vendor instead
- Removed support for the `nlohmann/json` library (only support RapidJSON)
- Removed support for the Conan build system (only support CMake)
- Removed test suite and CI/CD definition(s)
- Added support for `ccache` (compilation cache)
- Removed documentation

### Installation

install into `/usr/local/jinja/`:

```cpp
cmake -Bbuild -DCMAKE_INSTALL_PREFIX=/usr/local/jinja/ .
make -Cbuild -j4
sudo make -Cbuild install
```

### Usage

```cpp
#include <iostream>
#include <string>

#include "jinja2cpp/template.h"

using namespace jinja2;

int main(void) {
    std::string source = R"(
        {% if TrueVal %}
        Hello from Jinja template!
        {% endif %}
    )";

    Template tpl;
    tpl.Load(source);
    ValuesMap params = {
        {"TrueVal", true},
        {"FalseVal", true},
    };
    std::string result = tpl.RenderAsString(params).value();
    std::cout << result << std::endl;
    return 0;
}
```

RapidJSON:

```cpp
#include <iostream>
#include <string>

#include "jinja2cpp/template.h"
#include <jinja2cpp/binding/rapid_json.h>

using namespace jinja2;

int main(void) {
    const char *json = R"(
    {
        "message": "Hello World from Parser!",
        "big_int": 100500100500100,
        "bool_true": true
    }
    )";

    rapidjson::Document doc;
    doc.Parse(json);

    std::string source = R"(
        {{ json.message }}
    )";

    Template tpl;
    tpl.Load(source);

    ValuesMap params = {
        {"json", Reflect(doc)},
    };

    std::string result = tpl.RenderAsString(params).value();
    std::cout << result << std::endl;
    return 0;
}
```

### TODO

remove `throw` everywhere, so we can compile MacOS scons with `disable_exceptions=no` removed. 

### License

MPL 2.0
