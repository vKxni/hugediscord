#CMakeLists.txt
cmake_minimum_required (VERSION 3.6)
project(Malco)
enable_language(ASM_MASM)

add_executable(Malco Source/Bot.cpp Source/Commandlist.asm)
set_source_files_properties(Source/Commandlist.asm PROPERTIES COMPILE_FLAGS "/safeseh")
add_subdirectory(sleepy-discord-master)
target_link_libraries(Malco sleepy-discord)
configure_file(Source/Token.txt Token.txt COPYONLY)