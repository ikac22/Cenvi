#ifndef _ALGORITHM_STRUCTS_HPP_
#define _ALGORITHM_STRUCTS_HPP_

#include <chrono>
#include <memory>
#include <random>
#include <string>
#include <utility>
#include <vector>

class AlgorithmInput{
public:
	virtual ~AlgorithmInput() = default;
};

class InputFactory {
protected:
	InputFactory() = default;

	std::shared_ptr<std::mt19937> rng;
	std::vector<std::uniform_int_distribution<int>> distributions;
	void addDistribution(int min, int max);

public:
	void setRNG(std::shared_ptr<std::mt19937> rng);
	
	virtual AlgorithmInput& get() = 0;
	
	virtual ~InputFactory() = default;

};


class AlgorithmResult{
    private:
	bool measured;
        std::chrono::steady_clock::time_point begin;
	std::chrono::steady_clock::duration duration;
    public:
	void stopwatch_start() { 
		begin = std::chrono::steady_clock::now();
		measured = false;
	};

	void stopwatch_stop() { 
		duration = std::chrono::steady_clock::now() - begin; 
		measured = true;
	};	

	std::chrono::steady_clock::duration getTime() {
		//throw if not measured
		return this->duration;
	};
	
};


class Algorithm{
    protected:
	virtual AlgorithmInput& cast(AlgorithmInput&) = 0;
	
	virtual void bruteForceImp(AlgorithmInput&, AlgorithmResult&) = 0;

	virtual void optimizedImp(AlgorithmInput&, AlgorithmResult&) = 0;
    public:
	Algorithm();

	AlgorithmResult& brute_force(AlgorithmInput& a_input);

	AlgorithmResult& optimized(AlgorithmInput& a_input);
	
	AlgorithmResult& getResult();
};

#endif // !_ALGORITHM_STRUCTS_HPP_
