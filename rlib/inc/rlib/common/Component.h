#ifndef RLIB_COMMON_COMPONENT_H
#define RLIB_COMMON_COMPONENT_H


#include <pthread.h>
// for std::auto_ptr<T>
#include <memory>

/**
 * @file rlib/common/Component.h
 * @brief Provide a simple component framework with @ref rlib::common::Component and @ref rlib::common::ComponentPtr.
 */

namespace rlib{ namespace common{

/**
 * @class rlib::common::Component
 * @brief Inherit ths class to define a component.
 * @details By default, the component is a singleton. Use @ref ComponentPtr
 *   to reference this component.
 * @tparam T the class that inherete this template.
 */
template<typename T>
class Component;

/**
 * @class ComponentPtr
 * @brief Reference the component defined with @ref Component.
 * @example common/Component.cpp
 */
template<typename T>
class ComponentPtr;

/**
 * Component<T> and ComponentPtr<T>'s internal utilities
 * @internal
 */
namespace debug_component {

	template <typename B, typename D>
	struct IsBaseOf{
		typedef char (&yes)[1];
		typedef char (&no)[2];

		template <typename Base, typename Derived>
		struct Host
		{
		  operator Base*() const;
		  operator Derived*();
		};
		template <typename T> 
		static yes check(D*, T);
		static no check(B*, int);

		static const bool value = sizeof(check(Host<B,D>(), int())) == sizeof(yes);
	};
	
	/**
	 * @tparam b if true, StaticAssert will have a member function Assert().
	 */
	template <bool b>
	struct StaticAssert {};
	template <>
	struct StaticAssert<true>
	{
		static void Assert() {}
	};
	
	/** Work around for makeing friend. */
	template <typename T>
	struct FriendMaker
	{
		typedef T Type;
	};

} // namespace debug_component


template<class Derived>
class Component{
private:

	friend class debug_component::FriendMaker<Derived>::Type;
	Component(){} // Others can't derived directly from this component
	virtual ~Component(){}

	class PublicDerived;
	class FriendComponentPublicDerived{
		friend class Component<Derived>::PublicDerived;
		friend class Component<Derived>;

		struct PrivateStruct{};
	};

	/**
	 * make Derived non instanciable by others
	 */
	virtual void FinalMethod( typename FriendComponentPublicDerived::PrivateStruct ) = 0;

	class PublicDerived;
	friend class Component::PublicDerived;
	class PublicDerived: public Derived{
		virtual void FinalMethod( typename Component::FriendComponentPublicDerived::PrivateStruct) {};
	};


private:

	friend class ComponentPtr<Derived>;

	struct AutoDelete{
		Derived* ptr;
		AutoDelete(Derived* p = NULL){
			ptr=p;
		}
		~AutoDelete(){
			delete ptr;
		}
	};
	static AutoDelete autoDelete;

	class ScopeLock{
		pthread_mutex_t mutex;
	public:
		ScopeLock(){
			pthread_mutex_init(&mutex,NULL);
			pthread_mutex_lock(&mutex); 
		}
		~ScopeLock(){
			pthread_mutex_unlock(&mutex);
		}
	};
	
	static Derived* Instance(){
		if(autoDelete.ptr==NULL){
			ScopeLock lock()  ;
			(void)lock; // avoid warning

			typedef Derived* DerivedPtr;
			volatile DerivedPtr& vPtr = autoDelete.ptr;
			if(vPtr==NULL){
				vPtr = new  PublicDerived;
			}

			return autoDelete.ptr;
		}else{
			return autoDelete.ptr;
		}
	}
};

// initializations
template <typename T>
typename Component<T>::AutoDelete Component<T>::autoDelete = typename Component<T>::AutoDelete(NULL); 

template<typename T>
struct ComponentPtr{

	/**
	 * If compilation fails here, it means that class T doesn't derive from class Component<T>
	 */
	ComponentPtr() {debug_component::StaticAssert< debug_component::IsBaseOf< Component<T> , T>::value >::Assert();}
	T& operator * ()	{	return *(Component<T>::Instance()); }
	T* operator ->()	{	return Component<T>::Instance(); }
};



}} // namespace rlib::common



#endif

