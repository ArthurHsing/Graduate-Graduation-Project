clear all;close all;clc;
setSystemConfig();
[averageCompletionTime, p_off_device, p_off_edge, FR] = myOffload();