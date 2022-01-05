export module test;
export import :impl; // Note: GCC requires partitions to be re-exported, while MSVC doesn't

namespace test
{
export void greeter()
{
	greeterImpl();
}
}