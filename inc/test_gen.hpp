#ifndef _TEST_GEN_H_
#define _TEST_GEN_H_

#include <memory>
#include <random>
#include <vector>
#include "algorithm_structs.hpp"

class TestCase{
		
};

class TestGenerator final{
	std::random_device rd;
	std::shared_ptr<std::mt19937> rng;
	std::unique_ptr<InputFactory> input_factory;
public:
	// Constructors
	TestGenerator(std::unique_ptr<InputFactory> inputf);

	// Destructor
	~TestGenerator() = default;
};

#endif
