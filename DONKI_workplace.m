clear all
close all
clc

startDate = '2015-11-01'; % yyyy-MM-dd
endDate = '2015-11-31'; % yyyy-MM-dd
type = 'CME'; %all, FLR, SEP, CME, IPS, MPC, GST, RBE, report

[data, jd2000, Estimatedspeed, Estimatedopeninghalfangle, lon, lat] = DONKI_parse(startDate,endDate,type);

data(2).messageBody;
