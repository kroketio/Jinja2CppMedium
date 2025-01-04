cmake -Bbuild -DCMAKE_INSTALL_PREFIX="C:\Users\dsc\proj\build_root" .
cmake --build build -j6 --config Release
cmake --install build --config Release