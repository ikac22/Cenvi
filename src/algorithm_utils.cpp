#include"algorithm_utils.hpp"

using namespace std;

StringInput::StringInput(string& d): data(std::move(d)){}
IntInput::IntInput(int d): data(d){}
IntVectorInput::IntVectorInput(vector<int> d): data(std::move(d)){}

string StringInput::getString(){ return this->data; }
int IntInput::getInt(){ return this->data; }
vector<int> IntVectorInput::getIntVector(){ return this->data; }

StringFactory::StringFactory(int m_len, int min, int max){
	addDistribution(0, m_len); // str length
	addDistribution(min, max); // character
}

char StringFactory::genChar(){
	return distributions[1](*(this->rng));
}

StringInput& StringFactory::get() {
	int len = distributions[0](*(this->rng));
	string str;
	for(int i = 0; i < len; ++i)
		str += genChar();
	return *new StringInput(str);
}

IntFactory::IntFactory(int min, int max){
	addDistribution(min, max);
}
	
IntInput& IntFactory::get(){
	return *new IntInput(distributions[0](*(this->rng)));
}

IntVectorFactory::IntVectorFactory(int m_len, int min, int max){
	addDistribution(0, m_len);
	addDistribution(min, max);
}

IntVectorInput& IntVectorFactory::get(){
	int len = distributions[0](*(this->rng));
	vector<int> v;
	for(int i = 0; i < len; ++i)
		v.push_back(distributions[1](*(this->rng)));
	return *new IntVectorInput(v);
}
