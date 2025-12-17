function test=fitness(x,func_num)
persistent fhd
% if func_num==1                                
%     fhd=str2func('func1_sphere');                        
% elseif func_num==2
%     fhd=str2func('func2_schwefel_102');
% elseif func_num==3
%     fhd=str2func('func3_rosenbrock');
% elseif func_num==4
%     fhd=str2func('func4_shifted_ackley');
% elseif func_num==5
%     fhd=str2func('func5_shifted_rotated_ackley');
% elseif func_num==6
%     fhd=str2func('func6_shifted_griewank');
% elseif func_num==7
%     fhd=str2func('func7_shifted_rotated_griewank');
% elseif func_num==8
%     fhd=str2func('func8_rastrigin');
% elseif func_num==9
%     fhd=str2func('func9_rastrigin_rotated');
% elseif func_num==10
%     fhd=str2func('func10_shifted_noncontinuous_rastrigin');
% elseif func_num==11
%     fhd=str2func('func11_schwefel');
% elseif func_num==12
%     fhd=str2func('func12_CF1');
% elseif func_num==13
%     fhd=str2func('func13_CF6');
% elseif func_num==14
%     fhd=str2func('func14_schwefel_222');
% elseif func_num==15
%     fhd=str2func('func15_schwefel_221');
% elseif func_num==16
%     fhd=str2func('func16_generalized_penalized_1');
% elseif func_num==17
%     fhd=str2func('func17_generalized_penalized_2');
% elseif func_num==18
%     fhd=str2func('func18_schwefel_206');
% elseif func_num==19
%     fhd=str2func('func19_weierstrass_rotated');
% elseif func_num==20
%     fhd=str2func('func20_schwefel_213');
% elseif func_num==21
%     fhd=str2func('func21_kowalik');
% elseif func_num==22
%     fhd=str2func('func22_six_hump_camel_back');
% elseif func_num==23
%     fhd=str2func('func23_branin');
% elseif func_num==24
%     fhd=str2func('func24_hartman_1');
% elseif func_num==25
%     fhd=str2func('func25_hartman_2');
% elseif func_num==26
%     fhd=str2func('func26_shekel_1');
% elseif func_num==27
%     fhd=str2func('func27_shekel_2');
% elseif func_num==28
%     fhd=str2func('func28_shekel_3');
% elseif func_num==29
%     fhd=str2func('func_2Dentropy');
% end


if func_num==1                                
    fhd=str2func('func1_sphere');                        
elseif func_num==2
    fhd=str2func('func2_schwefel_102');
elseif func_num==3
    fhd=str2func('func3_rosenbrock');
elseif func_num==4
    fhd=str2func('func4_shifted_ackley');
elseif func_num==5
    fhd=str2func('func5_shifted_rotated_ackley');
elseif func_num==6
    fhd=str2func('func6_shifted_griewank');
elseif func_num==7
    fhd=str2func('func7_shifted_rotated_griewank');
elseif func_num==8
    fhd=str2func('func8_rastrigin');
elseif func_num==9
    fhd=str2func('func9_rastrigin_rotated');
elseif func_num==10
    fhd=str2func('func10_shifted_noncontinuous_rastrigin');
elseif func_num==11
    fhd=str2func('func14_schwefel_222');
elseif func_num==12
    fhd=str2func('func15_schwefel_221');
elseif func_num==13
    fhd=str2func('func16_generalized_penalized_1');
elseif func_num==14
    fhd=str2func('func17_generalized_penalized_2');
elseif func_num==15
    fhd=str2func('func18_schwefel_206');
elseif func_num==16
    fhd=str2func('func19_weierstrass_rotated');
elseif func_num==17
    fhd=str2func('func20_schwefel_213');
elseif func_num==18
    fhd=str2func('func21_kowalik');
elseif func_num==19
    fhd=str2func('func22_six_hump_camel_back');
elseif func_num==20
    fhd=str2func('func23_branin');
elseif func_num==21
    fhd=str2func('func24_hartman_1');
elseif func_num==22
    fhd=str2func('func25_hartman_2');
elseif func_num==23
    fhd=str2func('func26_shekel_1');
elseif func_num==24
    fhd=str2func('func27_shekel_2');
elseif func_num==25
    fhd=str2func('func28_shekel_3');
end

test=feval(fhd,x);
end

