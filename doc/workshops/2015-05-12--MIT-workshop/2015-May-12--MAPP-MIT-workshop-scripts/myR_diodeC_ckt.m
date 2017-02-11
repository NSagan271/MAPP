function cktnetlist = myR_diodeC_ckt()
	cktnetlist.cktname = 'myR_diodeC_ckt';
	cktnetlist.nodenames = {'1', '2'}; % non-ground nodes
	cktnetlist.groundnodename = 'gnd';

    cktnetlist = add_element(cktnetlist, vsrcModSpec(), 'V1', ...
       {'1', 'gnd'}, {}, {{'DC', 1}});
    cktnetlist = add_element(cktnetlist, myR(), 'R1', {'1', '2'}, {{'R', 1}});
    cktnetlist = add_element(cktnetlist, diodeC(), 'D1', {'2', 'gnd'});
end % myR_diodeC_ckt
