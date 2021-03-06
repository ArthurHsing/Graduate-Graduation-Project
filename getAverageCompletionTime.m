function[averageCompletionTime, p_off_device, p_off_edge, averageTime_Device, averageTime_Edge, averageTime_Cloud]...
    = getAverageCompletionTime(deviceCompletionTimeArrs, edgeCompletionTimeArr, cloudCompletionTimeArr)

    averageCompletionTime = mean([deviceCompletionTimeArrs, edgeCompletionTimeArr, cloudCompletionTimeArr]);
    if (isnan(averageCompletionTime))
        disp('debug');
    end
    averageTime_Device = mean(deviceCompletionTimeArrs);
    averageTime_Edge = mean(edgeCompletionTimeArr);
    averageTime_Cloud = mean(cloudCompletionTimeArr);
    ld = length(deviceCompletionTimeArrs);
    le = length(edgeCompletionTimeArr);
    lc = length(cloudCompletionTimeArr);
    disp(ld + le + lc);
    p_off_device = (le + lc)/(ld + le + lc);
    p_off_edge = lc/(le + lc);
    if (isnan(p_off_edge)) %当分母为0时，得到的值会是NaN
        p_off_edge = 0;
    end
    if (isnan(averageTime_Edge)) %当数组为空时，mean算出来会是NaN
        averageTime_Edge = 0;
    end
    if (isnan(averageTime_Cloud)) %
        averageTime_Cloud = 0;
    end
end