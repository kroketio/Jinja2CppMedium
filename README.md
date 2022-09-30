<div align="center"><img width="200" src="https://avatars0.githubusercontent.com/u/49841676?s=200&v=4"></div>

# Jinja2CppMedium

A "medium-lightweight" version of [jinja2cpp](https://github.com/jinja2cpp/Jinja2Cpp/) that features a better build system.

There is also [Jinja2CppLight](https://github.com/hughperkins/Jinja2CppLight). However, 
that version supports less Jinja2 features.

### Improvements

[jinja2cpp](https://github.com/jinja2cpp/Jinja2Cpp/) 
has a rather convoluted and unnecessarily complex CMake build 
script.

Our improvements are:

- A single, more straightforward `CMakeLists.txt` (100 lines)
- Removed all git submodules - link against (system) libs instead:
  - RapidJSON
  - Boost (`system`, `filesystem`)
  - fmt
- Some small header-only libraries are included in the repo as-is:
  - `string-view-lite`, `optional-lite`, `variant-lite`, `expected-lite`
- Removed support for the `nlohmann/json` library (only support RapidJSON)
- Removed support for the Conan build system (only support CMake)
- Removed test suite and CI/CD definition(s)
- Added support for `ccache` (compilation cache)
- Removed documentation

### Installation

install into `/usr/local/lib` and `/usr/local/include`:

```cpp
cmake -Bbuild .
make -Cbuild -j4
sudo make -Cbuild install
```

Copy `cmake/public/FindJinja2CppMedium.cmake` to your project so you may do:

```cmake
find_package(Jinja2CppMedium REQUIRED)
target_include_directories(your_app PRIVATE ${Jinja2CppMedium_INCLUDE_DIRS})
target_link_libraries(your_app ${Jinja2CppMedium_LIBRARIES})
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

### License

MPL 2.0
