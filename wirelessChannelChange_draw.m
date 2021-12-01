function [] = arriveRateChange_draw(changeRateResult)
    figure(1);
    avrTime_Real_myOffload = round([changeRateResult.avrTime.myOffload].*1000);
    avrTime_Real_mmssOffload = round([changeRateResult.avrTime.mmssOffload].*1000);
    avrTime_Real_randomOffload = round([changeRateResult.avrTime.randomOffload].*1000);
    avrTime_Real_allInDeviceOffload = round([changeRateResult.avrTime.allInDeviceOffload].*1000);
    avrTime_Real_allInEdgeOffload = round([changeRateResult.avrTime.allInEdgeOffload].*1000);
    avrTime_Real_allInCloudOffload = round([changeRateResult.avrTime.allInCloudOffload].*1000);
    Xlength = length(avrTime_Real_myOffload);
    Ylength = max([
        avrTime_Real_myOffload,...
        avrTime_Real_mmssOffload,...
        avrTime_Real_randomOffload,...
        avrTime_Real_allInDeviceOffload,...
        avrTime_Real_allInEdgeOffload,...
        avrTime_Real_allInCloudOffload...
    ]);
    avrTime_Real_X = 1:1:Xlength;
    plot(...
    avrTime_Real_X,avrTime_Real_myOffload,'-*r',...
    avrTime_Real_X,avrTime_Real_mmssOffload,'-og',...
    avrTime_Real_X,avrTime_Real_randomOffload,'-+b',...
    avrTime_Real_X,avrTime_Real_allInDeviceOffload,'-xc',...
    avrTime_Real_X,avrTime_Real_allInEdgeOffload,'-dm',...
    avrTime_Real_X,avrTime_Real_allInCloudOffload,'-sk'...
    ); %线性，颜色，标记
    % axis([0,6,0,700])  %确定x轴与y轴框图大小
    set(gca,'XTick',[0:1:(Xlength + 1)]) %x轴范围1-6，间隔1
    set(gca,'YTick',[0:50:(Ylength + 100)]) %y轴范围0-700，间隔100
    legend(...
    '我的卸载策略',...
    'mmss损失制卸载策略',...
    '随机卸载策略',...
    '全部在设备执行',...
    '全部在边缘服务器执行',...
    '全部在云服务器执行'...
    );   %右上角标注
    xlabel('时间（帧）')  %x轴坐标描述
    ylabel('任务平均完成时延（毫秒）') %y轴坐标描述

    figure(2);
    avrTime_Real_myOffload;
    avrTime_Theory_myOffload = round([changeRateResult.myOffloadTheoryData.avrTime].*1000);
    Xlength;
    Ylength = max([...
        avrTime_Real_myOffload,...
        avrTime_Theory_myOffload
    ]);
    RT_Compare_X = avrTime_Real_X;
    plot(...
    RT_Compare_X,avrTime_Real_myOffload,'-*r',...
    RT_Compare_X,avrTime_Theory_myOffload,'-ok'...
    ); %线性，颜色，标记
    % axis([0,6,0,700])  %确定x轴与y轴框图大小
    set(gca,'XTick',[0:1:(Xlength + 1)]) %x轴范围1-6，间隔1
    set(gca,'YTick',[0:10:Ylength]) %y轴范围0-700，间隔100
    legend(...
    '仿真结果',...
    '模型理论结果'...
    );   %右上角标注
    xlabel('时间（帧）')  %x轴坐标描述
    ylabel('任务平均完成时延（毫秒）') %y轴坐标描述

    hold on;

    figure(3);
    pOffDevice_Real = round([changeRateResult.myOffloadSimulationData.pOffDevice], 3);
    pOffDevice_Theory = round([changeRateResult.myOffloadTheoryData.pOffDevice], 3);
    XLength = 100;
    YLength = Ylength;
    RT_Compare_X;
    plot(...
    RT_Compare_X,pOffDevice_Real,'-*r',...
    RT_Compare_X,pOffDevice_Theory,'-ok'...
    ); %线性，颜色，标记
    % axis([0,6,0,700])  %确定x轴与y轴框图大小
    set(gca,'XTick',[0:1:(Xlength + 1)]) %x轴范围1-6，间隔1
    set(gca,'YTick',[0:0.1:1]) %y轴范围0-700，间隔100
    legend(...
    '仿真结果',...
    '模型理论结果'...
    );   %右上角标注
    xlabel('时间（帧）')  %x轴坐标描述
    ylabel('设备的任务卸载率') %y轴坐标描述

    figure(4);
    pOffEdge_Real = round([changeRateResult.myOffloadSimulationData.pOffEdge], 3);
    pOffEdge_Theory = round([changeRateResult.myOffloadTheoryData.pOffEdge], 3);
    XLength = 100;
    YLength = Ylength;
    RT_Compare_X;
    plot(...
    RT_Compare_X,pOffEdge_Real,'-*r',...
    RT_Compare_X,pOffEdge_Theory,'-ok'...
    ); %线性，颜色，标记
    % axis([0,6,0,700])  %确定x轴与y轴框图大小
    set(gca,'XTick',[0:1:(Xlength + 1)]) %x轴范围1-6，间隔1
    set(gca,'YTick',[0:0.1:1]) %y轴范围0-700，间隔100
    legend(...
    '仿真结果',...
    '模型理论结果'...
    );   %右上角标注
    xlabel('时间（帧）')  %x轴坐标描述
    ylabel('边缘节点的任务卸载率') %y轴坐标描述
end