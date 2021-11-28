function[averageCompletionTime, p_off_device, p_off_edge] = getAverageCompletionTime(deviceCompletionTimeArrs, edgeCompletionTimeArr, cloudCompletionTimeArr)
    averageCompletionTime = mean([deviceCompletionTimeArrs, edgeCompletionTimeArr, cloudCompletionTimeArr]);
    ld = length(deviceCompletionTimeArrs);
    le = length(edgeCompletionTimeArr);
    lc = length(cloudCompletionTimeArr);
    disp(ld + le + lc);
    p_off_device = (le + lc)/(ld + le + lc);
    p_off_edge = lc/(le + lc);
end