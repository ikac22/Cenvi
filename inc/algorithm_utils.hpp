#ifndef _HPP_ALGORITHM_UTILS_
#define _HPP_ALGORITHM_UTILS_

#include "algorithm_structs.hpp"


class StringInput: public AlgorithmInput{
	std::string data;
public:
	StringInput(std::string& d);
	std::string getString();
};

class IntInput: public AlgorithmInput{
	int data;
public:
	IntInput(int d);
	int getInt();
};

class IntVectorInput: public AlgorithmInput{
	std::vector<int> data;
public:
	IntVectorInput(std::vector<int> d);
	std::vector<int> getIntVector();
};

class StringFactory: public InputFactory{
protected:
	char genChar();
public:
	StringFactory(int m_len, int min = 32, int max = 126);
	StringInput& get() override;	
};

class IntFactory: public InputFactory{
public:
	IntFactory(int min, int max);
	IntInput& get() override;
};

class IntVectorFactory: public InputFactory{
public:
	IntVectorFactory(int m_len, int min, int max);
	IntVectorInput& get() override;	
};

#endif // !_HPP_ALGORITHM_UTILS_
