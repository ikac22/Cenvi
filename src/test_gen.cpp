#include "test_gen.hpp"

using namespace std;

TestGenerator::TestGenerator(unique_ptr<InputFactory> input_factory)
: rd(), rng(make_shared<mt19937>(rd())){
	this->input_factory = std::move(input_factory);
	this->input_factory->setRNG(this->rng);
	vector<int> a;
}
