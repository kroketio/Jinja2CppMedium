#include <iostream>
#include <string>
#include <chrono>

#include "jinja2cpp/template.h"

using namespace jinja2;

int main(void) {
  std::string source = R"(
{% if 'foo' == 'bar' %}
1
{% elif 'foo' == 'foo' %}
2
{% else %}
3
{% endif %}
    )";

  auto start = std::chrono::high_resolution_clock::now();
  Template tpl;
  tpl.Load(source);
  ValuesMap params = {
    {"TrueVal", true},
    {"FalseVal", true},
};
  std::string result = tpl.RenderAsString(params).value();

  auto end = std::chrono::high_resolution_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);

  std::cout << "Function call took " << duration.count() << " milliseconds." << std::endl;


  std::cout << result << std::endl;
  return 0;
}