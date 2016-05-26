clear all
close all
clc

startDate = '2015-05-1'; % yyyy-MM-dd
endDate = '2015-05-31'; % yyyy-MM-dd
type = 'all'; %all, FLR, SEP, CME, IPS, MPC, GST, RBE, report

[data, jd2000, Estimatedspeed, Estimatedopeninghalfangle, lon, lat] = DONKI_parse(startDate,endDate,type);

data(2).messageBody;
