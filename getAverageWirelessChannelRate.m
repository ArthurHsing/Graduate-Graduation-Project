function [averageWirelessChannelRate] = getAverageWirelessChannelRate()
    global systemConfig;
    bw = systemConfig.wireless.bandWidth;
    np = systemConfig.wireless.noisePower;
    tp = systemConfig.wireless.transmissionPower;
    deviceNum = systemConfig.deviceNum;
    averageWirelessChannelRate = 0;
    for i = 1:deviceNum
        gain = systemConfig.wireless.wireless_gains(i);
        rate = bw*log2(gain*tp/np);
        averageWirelessChannelRate = averageWirelessChannelRate + (1/deviceNum)*rate;
    end
end

