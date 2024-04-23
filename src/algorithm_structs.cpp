#include "algorithm_structs.hpp"
#include <random>

using namespace std;

void InputFactory::addDistribution(int min, int max){
	this->distributions.push_back(uniform_int_distribution<int>(min, max));	
}

void InputFactory::setRNG(shared_ptr<mt19937> rng){
	this->rng = rng;
}

// TODO: Implement Algorithm and AlgorithmResult
