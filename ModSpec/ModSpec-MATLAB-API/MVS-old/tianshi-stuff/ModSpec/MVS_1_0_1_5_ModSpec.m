function MOD = MVS_1_0_1_5_ModSpec(uniqID)
% f is separated
% use abs() instead of smoothabs
%author: Tianshi Wang   2014/1/25

% use the common ModSpec skeleton, sets up fields and defaults
	MOD = ModSpec_common_skeleton();

% set up data members defined in ModSpec_common_skeleton. These are
% used by the API functions defined there.

% version, help string: 
	MOD.version = 'daa_mosfet_VA_ModSpec v1.0.1 with modification 1';
	MOD.Usage = help('');

% uniqID
	if nargin < 1
		MOD.uniqID = '';
	else
		MOD.uniqID = uniqID;
	end

	MOD.model_name = 'mvs_si_1_0_1';
	MOD.model_description = '';

% real     version = 1.01;                             // MVS model version = 1.0.1
% integer  Type    = 1       from [-1 : 1] exclude 0;  // type of transistor. nFET Type=1; pFET Type=-1
% real     W       = 1e-4    from (0:inf);             // Transistor width [cm]
% real     Lgdr    = 80e-7   from (0:inf);             // Physical gate length [cm]. //    This is the designed gate length for litho printing.
% real     dLg     = 10.5e-7 from (0:inf);             // Overlap length including both source and drain sides [cm]  
% real     Cg      = 2.2e-6  from (0:inf);             // Gate-to-channel areal capacitance at the virtual source [F/cm^2]
% real     etov    = 1.3e-3  from (0:inf);             // Equivalent thickness of dielectric at S/D-G overlap [cm]
% real     delta   = 0.10    from [0:inf);             // Drain-induced-barrier-lowering (DIBL) [V/V]
% real     n0      = 1.5     from [0:inf);             // Subthreshold swing factor [unit-less] {typically between 1.0 and 2.0}
% real     Rs0     = 100     from (0:inf);             // Access resistance on s-terminal [Ohms-micron]
% real     Rd0     = 100     from (0:inf);             // Access resistance on d-terminal [Ohms-micron] 
%                                                      // Generally, Rs0 = Rd0 for symmetric source and drain
% real     Cif     = 1e-12   from [0:inf);             // Inner fringing S or D capacitance [F/cm] 
% real     Cof     = 2e-13   from [0:inf);             // Outer fringing S or D capacitance [F/cm] 
% real     vxo     = 0.765e7 from (0:inf);             // Virtual source injection velocity [cm/s]
% real     Mu      = 200     from (0:inf);             // Low-field mobility [cm^2/V.s]
% real     Beta    = 1.7     from (0:inf);             // Saturation factor. Typ. nFET=1.8, pFET=1.6
% real     Tjun    = 298     from [173:inf);           // Junction temperature [K]
% real     phib    = 1.2;                              // ~abs(2*phif)>0 [V]
% real     Gamma   = 0.0     from [0:inf);             // Body factor  [sqrt(V)]
% real     Vt0     = 0.486;                            // Strong inversion threshold voltage [V] 
% real     Alpha   = 3.5;                              // Empirical parameter for threshold voltage shift between strong and weak inversion.
% real     mc      = 0.2     from [0.01 : 10];         // Choose an appropriate value between 0.01 to 10 
%                                                      // For, values outside of this range,convergence or accuracy of results is not guaranteed
% integer CTM_select = 1     from [1 : inf);           // If CTM_select = 1, then classic DD-NVSAT model is used
%                                                      // For CTM_select other than 1,blended DD-NVSAT and ballistic charge transport model is used 
% real     CC      = 0       from [0:inf);             // Fitting parameter to adjust Vg-dependent inner fringe capacitances(Not used in this version)
% real     nd      = 0       from [0:inf);             // Punch-through factor [1/V]
%
% Tianshi: smoothing = 1e-5

	MOD.parm_names = {'version', 'Type', 'W', 'Lgdr', 'dLg', 'Cg', 'etov',...
	'delta', 'n0', 'Rs0', 'Rd0', 'Cif', 'Cof', 'vxo', 'Mu', 'Beta', 'Tjun',...
	'phib', 'Gamma', 'Vt0', 'Alpha', 'mc', 'CTM_select', 'CC', 'nd', 'smoothing'};

	MOD.parm_defaultvals = {1.01, 1, 1e-4, 80e-7, 10.5e-7, 2.2e-6, 1.3e-3,...
	0.10, 1.5, 100, 100, 1e-12, 2e-13, 0.765e7, 200, 1.7, 298, 1.2, 0.0,...
	0.486, 3.5, 0.2, 1, 0, 0, 1e-5};

	MOD.parm_vals = MOD.parm_defaultvals; 
	MOD.explicit_output_names = {'idb', 'igb', 'isb'}; % vecZ
	MOD.internal_unk_names = {'vdib', 'vsib'}; % vecY
	MOD.implicit_equation_names = {...
		'KCL-di', ...
		'KCL-si', ...
	};
	MOD.limited_var_names = {};
	MOD.vecXY_to_limitedvars_matrix = zeros(0, 5); %TODO

	MOD.u_names = {};

	MOD.NIL.node_names = {'d', 'g', 's', 'b' };
	MOD.NIL.refnode_name = 'b';

	% MOD.IO_names, MOD.OtherIO_names, MOD.NIL.io_types and
	% MOD.NIL.io_nodenames are set up by this helper function
	MOD = setup_IOnames_OtherIOnames_IOtypes_IOnodenames(MOD);

% Core functions: qi, fi, qe, fe: 
	MOD.fi = @fi; % fi(vecX, vecY, vecU, MOD)
	MOD.fe = @fe; % fe(vecX, vecY, vecU, MOD)
	MOD.qi = @qi; % qi(vecX, vecY, MOD)
	MOD.qe = @qe; % qe(vecX, vecY, MOD)

% Newton-Raphson initialization support

% Newton-Raphson limiting support

% Newton-Raphson convergence criterion support

% Equation and unknown scaling support

% Noise support

end % MOD constructor

%%%%%%%% STUFF BELOW IS NOT PART OF MOD API %%%%%%%%%%%%
%%%%%%%%%%% other local functions %%%%%%%%%%%%%%%
function fiout = fi(vecX, vecY, vecLim, u, MOD)
	fiout = fqei(vecX, vecY, vecLim, u, MOD, 'f', 'i');
end % fi(...)

function qiout = qi(vecX, vecY, vecLim, MOD)
	qiout = fqei(vecX, vecY, vecLim, [], MOD, 'q', 'i');
end % qi(...)

function feout = fe(vecX, vecY, vecLim, u, MOD)
	feout = fqei(vecX, vecY, vecLim, u, MOD, 'f', 'e');
end % fe(...)

function qeout = qe(vecX, vecY, vecLim, MOD)
	qeout = fqei(vecX, vecY, vecLim, [], MOD, 'q', 'e');
end % qe(...)

function fqout = fqei(vecX, vecY, vecLim, u, MOD, forq, eori)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	% set up scalar variables for the parms, vecX, vecY and u

	% create variables of the same names as the parameters and assign
	% them the values in MOD.parms
	% ideally, this should be a macro
	%	- could do this using a string and another eval()
	pnames = feval(MOD.parmnames,MOD);
	for i = 1:length(pnames)
		evalstr = sprintf('%s = MOD.parm_vals{i};', pnames{i});
		eval(evalstr);
	end

	% similarly, get values from vecX, named exactly the same as otherIOnames
	% get otherIOs from vecX
	oios = feval(MOD.OtherIONames,MOD);
	for i = 1:length(oios)
		evalstr = sprintf('%s = vecX(i);', oios{i});
		eval(evalstr); % should be OK for vecvalder
	end

	% do the same for vecY from internalUnknowns
	% get internalUnknowns from vecY
	iunks = feval(MOD.InternalUnkNames,MOD);
	for i = 1:length(iunks)
		evalstr = sprintf('%s = vecY(i);', iunks{i});
		eval(evalstr); % should be OK for vecvalder
	end

	% do the same for u from uNames
	unms = feval(MOD.uNames, MOD);
	for i = 1:length(unms)
		evalstr = sprintf('%s = u(i);', unms{i});
		eval(evalstr); % should be OK for vecvalder
	end
	% for this device, there are no us

	% end setting up scalar variables for the parms, vecX, vecY and u
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	vdb = vecX(1); vgb = vecX(2); vsb = vecX(3);
	vdib = vecY(1); vsib = vecY(2);

	vb  = 0;
	vd  = vdb + vb;
	vg  = vgb + vb;
	vs  = vsb + vb;
	vdi = vdib + vb;
	vsi = vsib + vb;


	if 1 == strcmp(eori,'e') % e
		if 1 == strcmp(forq, 'f') % f
			[iddi, idisi, isis] = daa_mosfet_core_model_I(vd, vg, vs, vb, vdi, vsi, MOD);
			% KCL at d
			fqout(1,1) = iddi;
			% KCL at g
			fqout(2,1) = 0;
			% KCL at s
			fqout(3,1) = -isis;
		else % q
			[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, MOD);
			% KCL at g
			fqout(2,1) = qgb; % TODO: vecvalder trick...
			% KCL at d
			fqout(1,1) = 0;
			% KCL at s
			fqout(3,1) = 0;
		end % forq
	else % i
		if 1 == strcmp(forq, 'f') % f
			[iddi, idisi, isis] = daa_mosfet_core_model_I(vd, vg, vs, vb, vdi, vsi, MOD);
			% KCL at di
			fqout(1,1) = idisi - iddi;
			% KCL at si
			fqout(2,1) = isis - idisi;
		else % q
			[iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, MOD);
			% KCL at di
			fqout(1,1) = qdib;
			% KCL at si
			fqout(2,1) = qsib;
		end
	end
end % fqei(...)

%%%%%%%%%%%%%  Internal Functions  %%%%%%%%%%%%%%%%%
%===================================================================================
%			this part is derived from daa_mosfet Verilog-A model
%===================================================================================

function [iddi, idisi, isis, qgb, qdib, qsib] = daa_mosfet_core_model(vd, vg, vs, vb, vdi, vsi, MOD)

	pnames = feval(MOD.parmnames, MOD);
	pvals  = feval(MOD.getparms, MOD);
	evalstr = '[';
	for i = 1:length(pnames)
		if i ~= length(pnames)
			evalstr = [evalstr, sprintf('%s, ', pnames{i})];
		else
			evalstr = [evalstr, sprintf('%s', pnames{i})];
		end
	end
	evalstr = [evalstr, '] = deal(pvals{:});'];
	eval(evalstr);

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams

	vgsi  = vg - vsi; 	% branch: (g, si)	br_gsi; %TODO: riscky naming convention, may cause conflictions, has to be checked
	vgdi  = vg - vdi; 	% branch: (g, di) 	br_gdi;
	vgs   = vg - vs;  	% branch: (g, s) 	br_gs;
	vgd   = vg - vd;  	% branch: (g, d) 	br_gd;
	vgb   = vg - vb;  	% branch: (g, b) 	br_gb;
	vdisi = vdi - vsi;	% branch: (di, si) 	br_disi;
	vds   = vd - vs;  	% branch: (d, s)	br_ds;
	vddi  = vd - vdi; 	% branch: (d, di) 	br_ddi;
	vdib  = vdi - vb; 	% branch: (di, b) 	br_dib;
	vbs   = vb - vs;  	% branch: (b, s) 	br_bs;
	vbsi  = vb - vsi; 	% branch: (b, si) 	br_bsi;
	vbd   = vb - vd;  	% branch: (b, d) 	br_bd;
	vbdi  = vb - vdi; 	% branch: (b, di) 	br_bdi;
	vsd   = vs - vd;  	% branch: (s, d) 	br_sd;
	vsidi = vsi - vdi;	% branch: (si, di) 	br_sidi;
	vsis  = vsi - vs; 	% branch: (si, s) 	br_sis;
	vsib  = vsi - vb; 	% branch: (si, b) 	br_sib;

	Vgsraw  = Type*(vgsi);
	Vgdraw  = Type*(vgdi);
	if (Vgsraw >= Vgdraw)
		Vds = Type*(vds); 
		Vgs = Type*(vgs);
		Vbs = Type*(vbs);
		Vdsi = Type*(vdisi);
		Vgsi = Vgsraw;
		Vbsi = Type*(vbsi);
		dir = 1;
	else
		Vds = Type*(vsd);
		Vgs = Type*(vgd);
		Vbs = Type*(vbd);
		Vdsi = Type*(vsidi);
		Vgsi = Vgdraw;
		Vbsi = Type*(vbdi);
		dir = -1;
	end

    % Parasitic element definition
    Rs = 1e-4/ W * Rs0;                           % s-terminal resistance [ohms]
    Rd = Rs;                                      % d-terminal resistance [ohms] For symmetric source and drain Rd = Rs. 
    % Rd = 1e-4/ W * Rd0;                         % d-terminal resistance [ohms] {Uncomment for asymmetric source and drain resistance.}
    Cofs = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % s-terminal outer fringing cap [F/cm]
    Cofd = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % d-terminal outer fringing cap [F/cm]
    Leff = Lgdr - dLg;                            % Effective channel length [cm]. After subtracting overlap lengths on s and d side 
    
    phit = dollar_vt(Tjun);                             % Thermal voltage, kT/q [V]
    me = (9.1e-31) * mc;                          % Carrier mass [Kg]
    n = n0 + nd * Vds;                            % Total subthreshold swing factor taking punchthrough into account [unit-less]
    nphit = n * phit;                             % Product of n and phit [used as one variable]
    aphit = Alpha * phit;                         % Product of Alpha and phit [used as one variable]
    
    % Correct Vgsi and Vbsi
    % Vcorr is computed using external Vbs and Vgs but internal Vdsi, Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and corrected Vgs, Vbs respectively.    
    Vtpcorr = Vt0 + Gamma * (sqrt(abs(phib - Vbs))- sqrt(phib))- Vdsi * delta; % Calculated from extrinsic Vbs
    eVgpre  = exp(( Vgs - Vtpcorr ) / ( aphit * 1.5 ));                         % Calculated from extrinsic Vgs
    FFpre   = 1.0/ ( 1.0 + eVgpre );                                           % Only used to compute the correction factor
    ab      = 2 * ( 1 - 0.99 * FFpre ) * phit;  
    Vcorr   = ( 1.0 + 2.0 * delta ) * ( ab/ 2.0 ) * ( exp( -Vdsi/ ab ));       % Correction to intrinsic Vgs
    Vgscorr = Vgsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vbscorr = Vbsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vt0bs   = Vt0 + Gamma * (sqrt( abs( phib - Vbscorr)) - sqrt( phib ));      % Computed from corrected intrinsic Vbs
    Vt0bs0  = Vt0 + Gamma * (sqrt( abs( phib - Vbsi)) - sqrt( phib ));         % Computed from uncorrected intrinsic Vbs
    Vtp     = Vt0bs - Vdsi * delta - 0.5 * aphit;                              % Computed from corrected intrinsic Vbs and intrinsic Vds
    Vtp0    = Vt0bs0 - Vdsi * delta - 0.5 * aphit;                             % Computed from uncorrected intrinsic Vbs and intrinsic Vds
    eVg     = exp(( Vgscorr - Vtp )/ ( aphit ));                               % Compute eVg factor from corrected intrinsic Vgs
    FF      = 1.0/ ( 1.0 + eVg );
    eVg0    = exp(( Vgsi - Vtp0 )/ ( aphit ));                                 % Compute eVg factor from uncorrected intrinsic Vgs
    FF0     = 1.0/ ( 1.0 + eVg0 );
    Qref    = Cg * nphit;    
    eta     = ( Vgscorr - ( Vt0bs - Vdsi * delta - FF * aphit ))/ ( nphit );   % Compute eta factor from corrected intrinsic Vgs and intrinsic Vds
    eta0    = ( Vgsi - ( Vt0bs0 - Vdsi * delta - FFpre * aphit ))/ ( nphit );  % Compute eta0 factor from uncorrected intrinsic Vgs and internal Vds. 
                                                                               % Using FF instead of FF0 in eta0 gives smoother capacitances.

    % Charge at VS in saturation (Qinv)
	if (eta  <= LARGE_VALUE)
        Qinv_corr = Qref * log( 1.0 + exp(eta) );
    else
        Qinv_corr = Qref * eta;
    end    
    if (eta0 <= LARGE_VALUE) 
        Qinv = Qref * log( 1.0 + exp(eta0) ); % Compute charge w/ uncorrected intrinsic Vgs for use later on in charge partitioning
	else
        Qinv = Qref * eta0;
    end

    %Transport equations
    vx0        = vxo;    
    Vdsats     = vx0 * Leff/ Mu;                            
    Vdsat      = Vdsats * ( 1.0 - FF ) + phit * FF; % Saturation drain voltage for current
    Vdratio    = abs( Vdsi/ Vdsat);
    Vdbeta     = pow( Vdratio, Beta);
    Vdbetabeta = pow( 1.0 + Vdbeta, 1.0/ Beta);
    Fsat       = Vdratio / Vdbetabeta; % Transition function from linear to saturation. 
                                       % Fsat = 1 when Vds>>Vdsat; Fsat= Vds when Vds<<Vdsat

    % Total drain current                                         
    Id = Qinv_corr * vx0 * Fsat * W;        

    % Calculation of intrinsic charge partitioning factors (qs and qd)
    Vgt = Qinv/ Cg; % Use charge computed from uncorrected intrinsic Vgs

    % Approximate solution for psis is weak inversion
    if (Gamma == 0)
        a  = 1.0;
        if (eta0 <= LARGE_VALUE)
			psis = phib + phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
        else 
			psis = phib + phit * ( 1.0 + log( eta0 ));
		end
    else
		if (eta0 <= LARGE_VALUE)
		   psis = phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( log( 1.0 + SMALL_VALUE + exp( eta0 ))));
	    else
		   psis = phib + ( 1.0 - Gamma )/ ( 1.0 + Gamma ) * phit * ( 1.0 + log( eta0 ));
		end
	    a = 1.0 + Gamma/ ( 2.0 * sqrt( abs( psis - ( Vbsi ))));
	end
    Vgta   = Vgt / a; % Vdsat in strong inversion
    Vdsatq = sqrt( FF0 * aphit * aphit + Vgta * Vgta); % Vdsat approx. to extend to weak inversion; 
                                                       % The Multiplier of phit has strong effect on Cgd discontinuity at Vd=0.

    % Modified Fsat for calculation of charge partitioning
    % DD-NVSAT charge
    Fsatq = abs( Vdsi/ Vdsatq )/ ( pow( 1.0 + pow( abs( Vdsi/ Vdsatq ), Beta ), 1.0/ Beta ));
    x     = 1.0 - Fsatq;
    den   = 15 * ( 1 + x ) * ( 1 + x );
    qsc   = Qinv *(6 + 12 * x + 8 * x * x + 4 * x * x * x)/ den;
    qdc   = Qinv *(4 + 8 * x + 12 * x * x + 6 * x * x * x)/ den;
    qi    = qsc + qdc; % Charge in the channel 
    

    % QB charge    
    kq  = 0.0;
    tol = ( SMALL_VALUE * vxo/ 100.0 ) * ( SMALL_VALUE * vxo/ 100.0 ) * me/ ( 2 * P_Q );
    if (Vdsi <= tol)
        kq2 = ( 2.0 * P_Q/ me * Vdsi )/ ( vx0 * vx0 ) * 10000.0;
        kq4 = kq2 * kq2;
        qsb = Qinv * ( 0.5 - kq2/ 24.0 + kq4/ 80.0 );
        qdb = Qinv * ( 0.5 - 0.125 * kq2 + kq4/ 16.0 );
    else
        kq  = sqrt( 2.0 * P_Q/ me * Vdsi )/ vx0 * 100.0;
        kq2 = kq * kq;
        qsb = Qinv * ( asinh( kq )/ kq - ( sqrt( kq2 + 1.0 ) - 1.0 )/ kq2);
        qdb = Qinv * (( sqrt( kq2 + 1.0 )- 1.0 )/ kq2);
    end

    % Flag for classic or ballistic charge partitioning:
    if (CTM_select == 1) % Ballistic blended with classic DD-NVSAT
        qs = qsc; % Calculation of "ballistic" channel charge partitioning factors, qsb and qdb.
        qd = qdc; % Here it is assumed that the potential increases parabolically from the
                  % virtual source point, where Qinv_corr is known to Vds-dvd at the drain.
    else % Hence carrier velocity increases linearly by kq (below) depending on the
        qs = qsc * ( 1 - Fsatq * Fsatq ) + qsb * Fsatq * Fsatq; % efecive ballistic mass of the carriers.
        qd = qdc * ( 1 - Fsatq * Fsatq ) + qdb * Fsatq * Fsatq;                
    end                                                
                                                    
                                
    % Body charge based on approximate surface potential (psis) calculation with delta=0 using psis=phib in Qb gives continuous Cgs, Cgd, Cdd in SI, while Cdd is smooth anyway.
    Qb = -Type * W * Leff * ( Cg * Gamma * sqrt( abs( psis - Vbsi )) + ( a - 1.0 )/ ( 1.0 * a ) * Qinv * ( 1.0 - qi ));

    % DIBL effect on drain charge calculation.
    % Calculate dQinv at virtual source due to DIBL only. Then:Correct the qd factor to reflect this channel charge change due to Vd
    % Vt0bs0 and FF=FF0 causes least discontinuity in Cgs and Cgd but produces a spike in Cdd at Vds=0 (in weak inversion.  But bad in strong inversion)
    etai = ( Vgsi - ( Vt0bs0 - FF * aphit ))/ ( nphit );
    if (etai <= LARGE_VALUE)
        Qinvi = Qref * log( 1.0 + exp( etai ));
    else
        Qinvi = Qref * etai;
    end
    dQinv     = Qinv - Qinvi;
    dibl_corr = ( 1.0 - FF0 ) * ( 1.0 - Fsatq ) * qi * dQinv;
    qd        = qd - dibl_corr;
         
    % Inversion charge partitioning to terminals s and d
    Qinvs = Type * Leff * (( 1 + dir ) * qs + ( 1 - dir ) * qd)/ 2.0;
    Qinvd = Type * Leff * (( 1 - dir ) * qs + ( 1 + dir ) * qd)/ 2.0;

    % Outer fringing capacitance
    Qsov = Cofs * ( vgsi );
    Qdov = Cofd * ( vgdi );

    % Inner fringing capacitance
    Vt0x = Vt0 + Gamma * ( sqrt( abs( phib - Type * ( vbsi ))) - sqrt(phib));
    Vt0y = Vt0 + Gamma * ( sqrt( abs( phib - Type * ( vbdi ))) - sqrt(phib));
    Fs_arg = ( Vgsraw - ( Vt0x - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
    if (Fs_arg <= LARGE_VALUE)
        Fs  = 1.0 + exp( Fs_arg );
        FFx = Vgsraw - nphit * log( Fs );
    else
        Fs  = 0.0; %    Not used
        FFx = Vgsraw - nphit * Fs_arg;
    end
    Fd_arg = ( Vgdraw - ( Vt0y - Vdsi * delta * Fsat ) + aphit * 0.5 )/ ( 1.1 * nphit );
    if (Fd_arg <= LARGE_VALUE)
        Fd  = 1.0 + exp( Fd_arg );
        FFy = Vgdraw - nphit * log( Fd );
    else
        Fd  = 0.0; %    Not used
        FFy = Vgdraw - nphit * Fd_arg;
    end
    Qsif = Type * ( Cif + CC * Vgsraw ) * FFx;
    Qdif = Type * ( Cif + CC * Vgdraw ) * FFy;
    
    % Partitioned charge
    Qs = -W * ( Qinvs + Qsov + Qsif ); %     s-terminal charge
    Qd = -W * ( Qinvd + Qdov + Qdif ); %     d-terminal charge
    Qg = -( Qs + Qd + Qb );            %     g-terminal charge

	% Contributions
	idisi =  Type*dir*Id;
	iddi =  (vddi)/Rd;
	isis =  (vsis)/Rs;
	qsib = Qs;  
	qdib = Qd;
	qgb = Qg; 
end % daa_mosfet_core_model

function [iddi, idisi, isis] = daa_mosfet_core_model_I(vd, vg, vs, vb, vdi, vsi, MOD)

	pnames = feval(MOD.parmnames, MOD);
	pvals  = feval(MOD.getparms, MOD);
	evalstr = '[';
	for i = 1:length(pnames)
		if i ~= length(pnames)
			evalstr = [evalstr, sprintf('%s, ', pnames{i})];
		else
			evalstr = [evalstr, sprintf('%s', pnames{i})];
		end
	end
	evalstr = [evalstr, '] = deal(pvals{:});'];
	eval(evalstr);

	SMALL_VALUE = 1e-10;
	LARGE_VALUE = 40;
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams

	vgsi  = vg - vsi; 	% branch: (g, si)	br_gsi; %TODO: riscky naming convention, may cause conflictions, has to be checked
	vgdi  = vg - vdi; 	% branch: (g, di) 	br_gdi;
	vgs   = vg - vs;  	% branch: (g, s) 	br_gs;
	vgd   = vg - vd;  	% branch: (g, d) 	br_gd;
	vgb   = vg - vb;  	% branch: (g, b) 	br_gb;
	vdisi = vdi - vsi;	% branch: (di, si) 	br_disi;
	vds   = vd - vs;  	% branch: (d, s)	br_ds;
	vddi  = vd - vdi; 	% branch: (d, di) 	br_ddi;
	vdib  = vdi - vb; 	% branch: (di, b) 	br_dib;
	vbs   = vb - vs;  	% branch: (b, s) 	br_bs;
	vbsi  = vb - vsi; 	% branch: (b, si) 	br_bsi;
	vbd   = vb - vd;  	% branch: (b, d) 	br_bd;
	vbdi  = vb - vdi; 	% branch: (b, di) 	br_bdi;
	vsd   = vs - vd;  	% branch: (s, d) 	br_sd;
	vsidi = vsi - vdi;	% branch: (si, di) 	br_sidi;
	vsis  = vsi - vs; 	% branch: (si, s) 	br_sis;
	vsib  = vsi - vb; 	% branch: (si, b) 	br_sib;

	Vgsraw  = Type*(vgsi);
	Vgdraw  = Type*(vgdi);
	if (Vgsraw >= Vgdraw)
		Vds = Type*(vds); 
		Vgs = Type*(vgs);
		Vbs = Type*(vbs);
		Vdsi = Type*(vdisi);
		Vgsi = Vgsraw;
		Vbsi = Type*(vbsi);
		dir = 1;
	else
		Vds = Type*(vsd);
		Vgs = Type*(vgd);
		Vbs = Type*(vbd);
		Vdsi = Type*(vsidi);
		Vgsi = Vgdraw;
		Vbsi = Type*(vbdi);
		dir = -1;
	end

    % Parasitic element definition
    Rs = 1e-4/ W * Rs0;                           % s-terminal resistance [ohms]
    Rd = Rs;                                      % d-terminal resistance [ohms] For symmetric source and drain Rd = Rs. 
    % Rd = 1e-4/ W * Rd0;                         % d-terminal resistance [ohms] {Uncomment for asymmetric source and drain resistance.}
    Cofs = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % s-terminal outer fringing cap [F/cm]
    Cofd = ( 0.345e-12/ etov ) * dLg/ 2.0 + Cof;  % d-terminal outer fringing cap [F/cm]
    Leff = Lgdr - dLg;                            % Effective channel length [cm]. After subtracting overlap lengths on s and d side 
    
    phit = dollar_vt(Tjun);                             % Thermal voltage, kT/q [V]
    me = (9.1e-31) * mc;                          % Carrier mass [Kg]
    n = n0 + nd * Vds;                            % Total subthreshold swing factor taking punchthrough into account [unit-less]
    nphit = n * phit;                             % Product of n and phit [used as one variable]
    aphit = Alpha * phit;                         % Product of Alpha and phit [used as one variable]
    
    % Correct Vgsi and Vbsi
    % Vcorr is computed using external Vbs and Vgs but internal Vdsi, Qinv and Qinv_corr are computed with uncorrected Vgs, Vbs and corrected Vgs, Vbs respectively.    
    Vtpcorr = Vt0 + Gamma * (sqrt(abs(phib - Vbs))- sqrt(phib))- Vdsi * delta; % Calculated from extrinsic Vbs
    eVgpre  = exp(( Vgs - Vtpcorr ) / ( aphit * 1.5 ));                         % Calculated from extrinsic Vgs
    FFpre   = 1.0/ ( 1.0 + eVgpre );                                           % Only used to compute the correction factor
    ab      = 2 * ( 1 - 0.99 * FFpre ) * phit;  
    Vcorr   = ( 1.0 + 2.0 * delta ) * ( ab/ 2.0 ) * ( exp( -Vdsi/ ab ));       % Correction to intrinsic Vgs
    Vgscorr = Vgsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vbscorr = Vbsi + Vcorr;                                                    % Intrinsic Vgs corrected (to be used for charge and current computation)
    Vt0bs   = Vt0 + Gamma * (sqrt( abs( phib - Vbscorr)) - sqrt( phib ));      % Computed from corrected intrinsic Vbs
    Vt0bs0  = Vt0 + Gamma * (sqrt( abs( phib - Vbsi)) - sqrt( phib ));         % Computed from uncorrected intrinsic Vbs
    Vtp     = Vt0bs - Vdsi * delta - 0.5 * aphit;                              % Computed from corrected intrinsic Vbs and intrinsic Vds
    Vtp0    = Vt0bs0 - Vdsi * delta - 0.5 * aphit;                             % Computed from uncorrected intrinsic Vbs and intrinsic Vds
    eVg     = exp(( Vgscorr - Vtp )/ ( aphit ));                               % Compute eVg factor from corrected intrinsic Vgs
    FF      = 1.0/ ( 1.0 + eVg );
    eVg0    = exp(( Vgsi - Vtp0 )/ ( aphit ));                                 % Compute eVg factor from uncorrected intrinsic Vgs
    FF0     = 1.0/ ( 1.0 + eVg0 );
    Qref    = Cg * nphit;    
    eta     = ( Vgscorr - ( Vt0bs - Vdsi * delta - FF * aphit ))/ ( nphit );   % Compute eta factor from corrected intrinsic Vgs and intrinsic Vds
    eta0    = ( Vgsi - ( Vt0bs0 - Vdsi * delta - FFpre * aphit ))/ ( nphit );  % Compute eta0 factor from uncorrected intrinsic Vgs and internal Vds. 
                                                                               % Using FF instead of FF0 in eta0 gives smoother capacitances.

    % Charge at VS in saturation (Qinv)
	if (eta  <= LARGE_VALUE)
        Qinv_corr = Qref * log( 1.0 + exp(eta) );
    else
        Qinv_corr = Qref * eta;
    end    

    %Transport equations
    vx0        = vxo;    
    Vdsats     = vx0 * Leff/ Mu;                            
    Vdsat      = Vdsats * ( 1.0 - FF ) + phit * FF; % Saturation drain voltage for current
    Vdratio    = abs( Vdsi/ Vdsat);
    Vdbeta     = pow( Vdratio, Beta);
    Vdbetabeta = pow( 1.0 + Vdbeta, 1.0/ Beta);
    Fsat       = Vdratio / Vdbetabeta; % Transition function from linear to saturation. 
                                       % Fsat = 1 when Vds>>Vdsat; Fsat= Vds when Vds<<Vdsat

    % Total drain current                                         
    Id = Qinv_corr * vx0 * Fsat * W;        

	% Contributions
	idisi =  Type*dir*Id;
	iddi =  (vddi)/Rd;
	isis =  (vsis)/Rs;
end % daa_mosfet_core_model_I

function out =  pow(a,b)
    out = a^b;
end % pow

function out = limexp(x)
	breakpoint = 40;
	maxslope = exp(breakpoint);
	out = exp(x.*(x <= breakpoint)).*(x <= breakpoint) + ...
		(x>breakpoint).*(maxslope + maxslope*(x-breakpoint));
end % limexp

function vt = dollar_vt(T)
	P_Q = 1.6021918e-19; % from constants.vams
	P_K = 1.3806503e-23; % from constants.vams
	vt = T * P_K / P_Q;
end % dollar_vt
