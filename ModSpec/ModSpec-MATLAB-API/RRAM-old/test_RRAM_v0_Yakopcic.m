clear ckt; 
ckt.cktname = 'RRAM v0 test bench';
ckt.nodenames = {'in'};
ckt.groundnodename = 'gnd';
tranfunc = @(t, args) args.offset+args.A*sawtooth(2*pi/args.T*t+args.phi, 0.5);
tranargs.offset = 0; tranargs.A = 0.5; tranargs.T = 1e-2; tranargs.phi=0;
ckt = add_element(ckt, vsrcModSpec(), 'Vin', ...
   {'in', 'gnd'}, {}, {{'DC', 1}, {'TRAN', tranfunc, tranargs}});
ckt = add_element(ckt, RRAM_v0_Yakopcic_ModSpec(), 'R1', {'in', 'gnd'}, {});

% set up DAE
DAE = MNA_EqnEngine(ckt);

% DC OP analysis
dcop = dot_op(DAE, [0;0;1]);
dcop.print(dcop); dcSol = dcop.getSolution(dcop);

% transient simulation, sweep Vin
tstart = 0; tstep = 0.5e-4; tstop = 2e-2;
xinit = [0; 0; 0];
LMSobj = dot_transient(DAE, xinit, tstart, tstep, tstop);
LMSobj.plot(LMSobj);

% get transient data, plot current in log scale
[tpts, sols] = LMSobj.getSolution(LMSobj);
figure; semilogy(sols(1,:), abs(sols(2,:)));
xlabel('Vin (V)'); ylabel('log(current) (A)'); grid on;

%{
% homotopy analysis
startLambda = 1; stopLambda = -1; lambdaStep = -1e-1;
hom = homotopy(DAE, 'Vin:::E', 'input', dcSol, startLambda, lambdaStep, stopLambda);
hom.plot(hom);
%}
