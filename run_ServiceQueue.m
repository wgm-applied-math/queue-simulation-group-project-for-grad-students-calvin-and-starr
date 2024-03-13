% Script that runs a ServiceQueue simulation many times and plots a
% histogram

%% Set up

% Set up to run 100 samples of the queue.
n_samples = 100;

% Each sample is run up to a maximum time of 1000.
max_time = 1000;

% Record how many customers are in the system at the end of each sample.
NInSystemSamples = cell([1, n_samples]);

%% Run the queue simulation

% The statistics seem to come out a little weird if the log interval is too
% short, apparently because the log entries are not independent enough.  So
% the log interval should be long enough for several arrival and departure
% events happen.
for sample_num = 1:n_samples
    q = ServiceQueue(LogInterval=10);
    q.schedule_event(Arrival(1, Customer(1)));
    run_until(q, max_time);
    % Pull out samples of the number of customers in the queue system. Each
    % sample run of the queue results in a column of samples of customer
    % counts, because tables like q.Log allow easy extraction of whole
    % columns like this.
    NInSystemSamples{sample_num} = q.Log.NWaiting + q.Log.NInService;
end

% Join all the samples. "vertcat" is short for "vertical concatenate",
% meaning it joins a bunch of arrays vertically, which in this case results
% in one tall column.
NInSystem = vertcat(NInSystemSamples{:});

% MATLAB-ism: When you pull multiple items from a cell array, the result is
% a "comma-separated list" rather than some kind of array.  Thus, the above
% means
%
%    NInSystem = horzcat(NInSystemSamples{1}, NInSystemSamples{2}, ...)
%
% which horizontally concatenates all the lists of numbers in
% NInSystemSamples.
%
% This is roughly equivalent to "splatting" in Python, which looks like
% f(*args).

%% Make a picture

systemtotallist = [];
systemwaitinglist = [];
systemservicelist = [];
for n=1:length(q.Served)
    systemtotal = q.Served{1,n}.DepartureTime-q.Served{1,n}.ArrivalTime;
    systemwaiting = q.Served{1,n}.BeginServiceTime-q.Served{1,n}.ArrivalTime;
    systemservice = q.Served{1,n}.DepartureTime-q.Served{1,n}.BeginServiceTime;
    systemtotallist(end+1) = systemtotal;
    systemwaitinglist(end+1)= systemwaiting;
    systemservicelist(end+1)= systemservice;
end
for n=1:length(q.Reneged)
    systemtotal = q.Reneged{1,n}.RenegTime-q.Reneged{1,n}.ArrivalTime;
    systemwaitinglist(end+1)= systemtotal;
end

probreneg = length(q.Reneged)/(length(q.Reneged)+length(q.Served));

% Start with a histogram.  The result is an empirical PDF, that is, the
% area of the bar at horizontal index n is proportional to the fraction of
% samples for which there were n customers in the system.

fig=figure();
t=tiledlayout(fig,1,1);
ax = nexttile(t);

% MATLAB-ism: Once you've created a picture, you can use "hold on" to cause
% further plotting function to work with the same picture rather than
% create a new one.
%hold on;
hold(ax,'on');

h = histogram(ax,NInSystem, Normalization="probability", BinMethod="integers");

%adjProb = [.527169, .351446, .1004131429, .018256935, .002434258, .0002562377];

%xVal = [0, 1, 2, 3, 4, 5];

%plot(ax, xVal, adjProb, 'o', MarkerEdgeColor='k', MarkerFaceColor='r');


%Total Time Histogram
fig2=figure();
t2=tiledlayout(fig2,1,1);
ax2= nexttile(t2);

totalhist = histogram(ax2,systemtotallist,Normalization="probability",BinMethod="auto");



%Waiting Time Histogram
fig3=figure();
t3=tiledlayout(fig3,1,1);
ax3= nexttile(t3);

waitinghist = histogram(ax3,systemwaitinglist,Normalization="probability",BinMethod="auto");




%Service Time Histogram
fig4=figure();
t4=tiledlayout(fig4,1,1);
ax4= nexttile(t4);

servicehist = histogram(ax4,systemservicelist,Normalization="probability",BinMethod="auto");



%Reneging Histogram
fig5=figure();
t5=tiledlayout(fig5,1,1);
ax5= nexttile(t5);

servereneg=length(q.Served)+length(q.Reneged);
x=0:servereneg;
pd = binopdf(x,servereneg,probreneg);

bar(ax5,x,pd)
xlabel='Observation';
ylabel='Probability';


% For comparison, plot the theoretical results for a M/M/1 queue.
% The agreement isn't all that good unless you run for a long time, say
% max_time = 10,000 units, and LogInterval is large, say 10.
%rho = q.ArrivalRate / q.DepartureRate;
%P0 = 1 - rho;
%nMax = 10;
%ns = 0:nMax;
%P = zeros([1, nMax+1]);
%P(1) = P0;
%for n = 1:nMax
 %   P(1+n) = P0 * rho^n;
%end
%plot(ns, P, 'o', MarkerEdgeColor='k', MarkerFaceColor='r');

% This sets some paper-related properties of the figure so that you can
% save it as a PDF and it doesn't fill a whole page.
% gcf is "get current figure handle"
% See https://stackoverflow.com/a/18868933/2407278
fig = gcf;
fig.Units = 'inches';
screenposition = fig.Position;
fig.PaperPosition = [0 0 screenposition(3:4)];
fig.PaperSize = [screenposition(3:4)];