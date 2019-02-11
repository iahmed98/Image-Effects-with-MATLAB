% Stack.m
% 
% Author: Imtiaz Ahmed 
% CSc 4630/6630 Semester Project
%
% Description: This program serves as a Stack data structure, and is used
% to keep track of user modifications in 'project.m'

classdef Stack
    properties
        stack;
    end
    methods
        % Constructor, initialises a stack that holds value in data
        function init = Stack(data)
            init.stack = data;
        end
        
        % Returns a stack with 'data' pushed on.
        function ret = push(self, data)
            self.stack{1,size(self.stack,2)+1} = data;
            ret = Stack(self.stack);
        end
        
        % Returns the element at the top of the stack.
        function ret = peek(self)
            ret = self.stack{1,size(self.stack,2)};
        end
        
        % Returns a stack with the top element popped.
        function ret = pop(self)           
            ret = Stack(self.stack(1,1:size(self.stack,2)-1));
        end
    end
end