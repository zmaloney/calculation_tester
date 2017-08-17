function [ input_1, input_2, answer] = newproblem( )
%NEWPROBLEM Summary of this function goes here
%   Detailed explanation goes here
    input_1 = randi(90, 1, 1) + 10;
    input_2 = randi(88, 1, 1) + 11;
    answer = input_1(1) * input_2(1); 
end

