classdef Reneg < Event
    % Reneg Subclass of Event that represents the departure of a
    % Customer.

    properties
        % ServerIndex - Index of the service station from which the
        % departure occurred

        % no need for serverIndex
        %ServerIndex;

        % May need to as a waiting property...
        CustomerIndex;
    end
    methods
        function obj = Reneg(Time, CustomerIndex) % removed ServerIndex. may need to add something for waiting
            % Departure - Construct a departure event from a time and
            % server index.
            arguments
                Time = 0.0;

                % see parameters
                CustomerIndex = 0;

                % No need for a server
                %ServerIndex = 0;
            end
            
            % MATLAB-ism: This incantation is how to invoke the superclass
            % constructor.
            obj = obj@Event(Time);

            % removing alocation of server because reneging happens without
            % interaction with the server.
            %obj.ServerIndex = ServerIndex;

            obj.CustomerIndex = CustomerIndex;

        end
        function varargout = visit(obj, other)
            % visit - Call handle_departure

            % MATLAB-ism: This incantation means whatever is returned by
            % the call to handle_departure is returned by this visit
            % method.
            [varargout{1:nargout}] = handle_Reneg(other, obj);
        end
    end
end