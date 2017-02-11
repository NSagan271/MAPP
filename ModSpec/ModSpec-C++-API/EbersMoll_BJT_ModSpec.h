#ifndef EBERSMOLL_BJTMODSPEC
#define EBERSMOLL_BJTMODSPEC
#include "ee_model_initlimiting.h"

class EbersMoll_BJT_ModSpec : public ee_model_initlimiting {
	public: 
		EbersMoll_BJT_ModSpec();
		~EbersMoll_BJT_ModSpec(){};
	protected:
		template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
		  vector<TOUT> fe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU);

		template <typename TOUT, typename TX, typename TY, typename TLIM>
		  vector<TOUT> qe_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim);

		template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
		  vector<TOUT> fi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim, vector<TU>& vecU);

		template <typename TOUT, typename TX, typename TY, typename TLIM>
		  vector<TOUT> qi_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLim);

	public:
		vector<double> initGuess(vector<double>& vecU);

	protected:
		template <typename TOUT, typename TX, typename TY, typename TLIM, typename TU>
		  vector<TOUT> limiting_tmpl(vector<TX>& vecX, vector<TY>& vecY, vector<TLIM>& vecLimOld, vector<TU>& vecU);

		template <typename T>
		  T pnjlim(T vnew, T vold, double vt, double vcrit);

		template <typename T>
		  T diode_Id(T vd, double Is, double Vt);

		// All the functions below can stay exactly identical for any other device. They can't be moved
		// to ModSpec_Element.h yet because C++ does not support inheriting virtual template functions.
		// They are included from ModSpec_Element_common_includes.h
		#include "ModSpec_Element_initlimiting_common_includes.h"
		// TODO: move the templates above also to ModSpec_Element_initlimiting_common_includes.h
};
#endif
