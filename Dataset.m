clear
clc
% 设置数据集参数

activatedSignals = struct(...
    'Type', {}, ...
    'Start', [], ...
    'Duration', [], ...
    'Freq', [], ...
    'Rate', [], ...
    'Bandwidth',[]...
);
ModType={'BPSK';'QPSK';'8PSK';'16QAM';'64QAM';'FM';'AM-DSB';'AM-SSB';'MSK'};
% --- MODIFIED: 添加多类别标签映射和激活信号记录器 ---
ModClassMap = containers.Map(...
    {'BPSK', 'QPSK', '8PSK', '16QAM', '64QAM', 'FM', 'AM-DSB', 'AM-SSB', 'MSK'}, ...
    [1, 2, 3, 4, 5, 6, 7, 8, 9]...
);


%  设置图像参数
cmap = hot(256);
imageSize=[1024 741]; % 注意，这里的参数设置

% 其他参数保持不变
CenterFreqSet = [3e6 8e6 11e6 16e6 22e6 26e6];
SymbolRateSet = [1.2e3 2.4e3 4.8e3 9.6e3 19.2e3];
SymbolDurationSet = [0.01 0.03 0.05 0.08 0.1 0.12 0.2];
SymbolStartTime = [0.1 0.3 0.5 0.8 1.0 1.2 1.5]; % 注意调整起始时间范围
SampleNum=50;

% 设置参数
sampleRate = 2.4e6; % 采样率为2.4MHz
duration = 1.8; % 样本时长为1.8秒
EquCentFreq=mod(CenterFreqSet,sampleRate);
[tmpval tmpidx]=find(EquCentFreq>sampleRate./2);
EquCentFreq(tmpidx)=EquCentFreq(tmpidx)-sampleRate;
FreRes=sampleRate./imageSize(1);

% 设置频谱泄露的系数
SignalSpan=4;

% 设置成型滤波
load MyRcos.mat

% 设置滚降系数
rolloff = 0.35;  % 所有调制类型使用同一滚降系数
 
% 创建时间轴
numSamples = round(sampleRate * duration); % 四舍五入取整
time = linspace(0, duration, numSamples);

% 打开文件，准备记录信号的参数
fid=fopen('SignalParameter.txt','w');
filename = 'Signal_%d'

% 创建参数存储目录
paramDir = 'C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/Params/';
if ~exist(paramDir, 'dir')
    mkdir(paramDir);
end

for SampleNumIter=1:SampleNum
    Signal = zeros(1, length(time));
    activatedSignals = struct('Type',{}, 'Start',[], 'Duration',[], 'Freq',[], 'Rate',[],'Bandwidth',[]);  
    labelMatrix = zeros(imageSize(1), imageSize(2), 'uint8'); % 初始化标签矩阵

%全覆盖信号
%ModTypeRandInd=randi(1,1,length(ModType))

%随机信号
ModTypeRandInd=randi([0 1],1,length(ModType))

fwrite(fid,sprintf(filename, SampleNumIter));
fwrite(fid,sprintf('\n'));

SignalLabel=[];
%% 
% 生成BPSK信号
if ModTypeRandInd(1)==1
    bpskDuration = SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % BPSK时长
    bpskStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); % BPSK起始时间
    symbolRate = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % 符号速率
    bpskCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % BPSK中心频率
    SamplePerSymbol=sampleRate./symbolRate; %  每个BPSK符号中的采样点个数

%     把参入写入文件
    fwrite(fid,'BPSK');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([bpskStart bpskDuration bpskCenterFreq symbolRate]));
    fwrite(fid,sprintf('\n'));
    % 生成BPSK调制信号
    bpskSymbols = randi([0, 1], 1, round(bpskDuration*symbolRate));
    bpskSymbols=pskmod(bpskSymbols, 2, pi);
    bpskSymbolsFromSample=kron(bpskSymbols,ones(1,SamplePerSymbol));
    bpskSymbolsFromSample=filter(MyRcos,1,bpskSymbolsFromSample); % 成型滤波防止信号的带宽太宽
    bpskSymbolsFromSample=bpskSymbolsFromSample./max(abs(bpskSymbolsFromSample)); % 调整数值，否则和模拟信号的差别太大

    bpskSignal=zeros(1,length(time));
    bpskSignal(time >= bpskStart & time < bpskStart+bpskDuration) = bpskSymbolsFromSample .* exp(j*2*pi*bpskCenterFreq*time(time >= bpskStart & time < bpskStart+bpskDuration));

    Signal=Signal+bpskSignal;

    % 计算带宽
    bandwidth = symbolRate * (1 + rolloff); % 数字调制带宽公式


    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', 'BPSK',...
        'Start', bpskStart,...
        'Duration', bpskDuration,...
        'Freq', bpskCenterFreq,...
        'Rate', symbolRate,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );
% --- 无其他操作 ---


%     % 可视化结果
     %figure;
     %plot(time, real(bpskSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的BPSK信号样本');
end

%% 
% 生成QPSK信号
if ModTypeRandInd(2)==1
    qpskDuration = SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % QPSK时长
    qpskStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); %QPSK起始时间
    symbolRateQPSK = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % QPSK符号速率
    qpskCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % QPSK中心频率
    samplePerSymbolQPSK = round(sampleRate / symbolRateQPSK); % 每个QPSK符号中的采样点个数

    %     把参入写入文件
    fwrite(fid,'QPSK');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([qpskStart qpskDuration qpskCenterFreq symbolRateQPSK]));
    fwrite(fid,sprintf('\n'));
    % 生成QPSK调制信号
    qpskSymbols = randi([0, 3], 1, round(qpskDuration*symbolRateQPSK));
    qpskSymbols = pskmod(qpskSymbols, 4, pi/4);
    qpskSymbolsFromSample = kron(qpskSymbols, ones(1, samplePerSymbolQPSK));
    qpskSymbolsFromSample=filter(MyRcos,1,qpskSymbolsFromSample);
    qpskSymbolsFromSample=qpskSymbolsFromSample./max(abs(qpskSymbolsFromSample)); % 调整数值，否则和模拟信号的差别太大

    qpskSignal = zeros(1, length(time));
    qpskSignal(time >= qpskStart & time < qpskStart+qpskDuration) = qpskSymbolsFromSample .* exp(j*2*pi*qpskCenterFreq*time(time >= qpskStart & time < qpskStart+qpskDuration));

    Signal=Signal+qpskSignal;

    % 计算带宽
    bandwidth = symbolRateQPSK * (1 + rolloff); % 数字调制带宽公式

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', 'QPSK',...
        'Start', qpskStart,...
        'Duration', qpskDuration,...
        'Freq', qpskCenterFreq,...
        'Rate', symbolRateQPSK,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );
  
%     % 可视化结果
     %figure;
     %plot(time, real(qpskSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的QPSK信号样本');
end
%% 
% 生成8PSK信号
if ModTypeRandInd(3)==1
    p8skDuration = SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % 8PSK时长
    p8skStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); %8PSK起始时间
    symbolRateP8SK = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % 8PSK符号速率
    p8skCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % 8PSK中心频率
    samplePerSymbolP8SK = round(sampleRate / symbolRateP8SK); % 每个8PSK符号中的采样点个数

     %     把参入写入文件
    fwrite(fid,'8PSK');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([p8skStart p8skDuration p8skCenterFreq symbolRateP8SK]));
    fwrite(fid,sprintf('\n'));
    % 生成P8SK调制信号
    p8skSymbols = randi([0, 7], 1, round(p8skDuration*symbolRateP8SK));
    p8skSymbols = pskmod(p8skSymbols, 8, pi/8);
    p8skSymbolsFromSample = kron(p8skSymbols, ones(1, samplePerSymbolP8SK));
    p8skSymbolsFromSample=filter(MyRcos,1,p8skSymbolsFromSample);
    p8skSymbolsFromSample=p8skSymbolsFromSample./max(abs(p8skSymbolsFromSample)); % 调整数值，否则和模拟信号的差别太大

    p8skSignal = zeros(1, length(time));
    p8skSignal(time >= p8skStart & time < p8skStart+p8skDuration) = p8skSymbolsFromSample .* exp(j*2*pi*p8skCenterFreq*time(time >= p8skStart & time < p8skStart+p8skDuration));

    Signal=Signal+p8skSignal;

    % 计算带宽
    bandwidth = symbolRateP8SK * (1 + rolloff); % 数字调制带宽公式

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', '8PSK',...
        'Start', p8skStart,...
        'Duration', p8skDuration,...
        'Freq', p8skCenterFreq,...
        'Rate', symbolRateP8SK,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );
    
  
%     % 可视化结果
     %figure;
     %plot(time, real(p8skSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的8PSK信号样本');
end
%% /
% 生成16QAM信号
if ModTypeRandInd(4)==1
    qam16Duration = SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % 16QAM时长
    qam16Start = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); %16QAM起始时间
    symbolRateQAM16 = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % 16QAM符号速率
    qam16CenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % 16QAM中心频率
    samplePerSymbolQAM16 = round(sampleRate / symbolRateQAM16); % 每个16QAM符号中的采样点个数

     %     把参入写入文件
    fwrite(fid,'16QAM');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([qam16Start qam16Duration qam16CenterFreq symbolRateQAM16]));
    fwrite(fid,sprintf('\n'));
    % 生成16QAM调制信号
    qam16Symbols = randi([0, 15], 1, round(qam16Duration*symbolRateQAM16));
    qam16Symbols = qammod(qam16Symbols, 16);
    qam16SymbolsFromSample = kron(qam16Symbols, ones(1, samplePerSymbolQAM16));
    qam16SymbolsFromSample=filter(MyRcos,1,qam16SymbolsFromSample);
    qam16SymbolsFromSample=qam16SymbolsFromSample./max(abs(qam16SymbolsFromSample)); % 调整数值，否则和模拟信号的差别太大

    qam16Signal = zeros(1, length(time));
    qam16Signal(time >= qam16Start & time < qam16Start+qam16Duration) = qam16SymbolsFromSample .* exp(j*2*pi*qam16CenterFreq*time(time >= qam16Start & time < qam16Start+qam16Duration));

    Signal=Signal+qam16Signal;

    % 计算带宽
    bandwidth = symbolRateQAM16 * (1 + rolloff); % 数字调制带宽公式

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', '16QAM',...
        'Start', qam16Start,...
        'Duration', qam16Duration,...
        'Freq', qam16CenterFreq,...
        'Rate', symbolRateQAM16,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );

   
%     % 可视化结果
     %figure;
     %plot(time, real(qam16Signal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的16QAM信号样本');
end
%% 
% 生成64QAM信号
if ModTypeRandInd(5)==1
    qam64Duration = SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % 64QAM时长
    qam64Start = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); %64QAM起始时间
    symbolRateQAM64 = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % 64QAM符号速率
    qam64CenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % 64QAM中心频率
    samplePerSymbolQAM64 = round(sampleRate / symbolRateQAM64); % 每个64QAM符号中的采样点个数

     %     把参入写入文件
    fwrite(fid,'64QAM');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([qam64Start qam64Duration qam64CenterFreq symbolRateQAM64]));
    fwrite(fid,sprintf('\n'));
    % 生成64QAM调制信号
    qam64Symbols = randi([0, 63], 1, round(qam64Duration*symbolRateQAM64));
    qam64Symbols = qammod(qam64Symbols, 64);
    qam64SymbolsFromSample = kron(qam64Symbols, ones(1, samplePerSymbolQAM64));
    qam64SymbolsFromSample=filter(MyRcos,1,qam64SymbolsFromSample);
    qam64SymbolsFromSample=qam64SymbolsFromSample./max(abs(qam64SymbolsFromSample)); % 调整数值，否则和模拟信号的差别太大

    qam64Signal = zeros(1, length(time));
    qam64Signal(time >= qam64Start & time < qam64Start+qam64Duration) = qam64SymbolsFromSample .* exp(j*2*pi*qam64CenterFreq*time(time >= qam64Start & time < qam64Start+qam64Duration));

    Signal=Signal+qam64Signal;

    % 计算带宽
    bandwidth = symbolRateQAM64 * (1 + rolloff); % 数字调制带宽公式

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', '64QAM',...
        'Start', qam64Start,...
        'Duration', qam64Duration,...
        'Freq', qam64CenterFreq,...
        'Rate', symbolRateQAM64,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );
  
%     % 可视化结果
     %figure;
     %plot(time, real(qam64Signal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的64QAM信号样本');
end
%% 
% 生成FM信号
if ModTypeRandInd(6)==1
    fmDuration =SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % FM时长
    fmStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); % FM起始时间
    symbolRateFM = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % FM符号速率
    fmCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % FM中心频率
    samplePerSymbolFM = round(sampleRate / symbolRateFM); % 每个FM符号中的采样点个数
    fDev = 50; % Set the frequency deviation to 50 Hz.

     %     把参入写入文件
    fwrite(fid,'FM');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([fmStart fmDuration fmCenterFreq symbolRateFM]));
    fwrite(fid,sprintf('\n'));
    % 生成FM调制信号
    fmSymbols = randn(1, round(fmDuration*symbolRateFM));
    fmSymbols = fmmod(fmSymbols,1e6,sampleRate,fDev);
    fmSymbolsFromSample = kron(fmSymbols, ones(1, samplePerSymbolFM));
    fmSignal = zeros(1, length(time));
    fmSignal(time >= fmStart & time < fmStart+fmDuration) = fmSymbolsFromSample .* exp(j*2*pi*(fmCenterFreq)*time(time >= fmStart & time < fmStart+fmDuration));

    Signal=Signal+fmSignal;   

    % 计算FM带宽（卡森规则）
    fDev = 50; % 用户代码中固定为50 Hz
    bandwidth = 2 * (fDev + symbolRateFM/2); % FM带宽公式

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', 'FM',...
        'Start', fmStart,...
        'Duration', fmDuration,...
        'Freq', fmCenterFreq,...
        'Rate', symbolRateFM,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );


%     % 可视化结果
     %figure;
     %plot(time, real(fmSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的fm信号样本');
end
%% 
% 生成AM-DSB信号
if ModTypeRandInd(7)==1
    dsbDuration =SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % DSB时长
    dsbStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); % DSB起始时间
    symbolRateDSB = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % DSB符号速率
    dsbCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % DSB中心频率
    samplePerSymbolDSB = round(sampleRate / symbolRateDSB); % 每个DSB符号中的采样点个数

 %     把参入写入文件
    fwrite(fid,'AM-DSB');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([dsbStart dsbDuration dsbCenterFreq symbolRateDSB]));
    fwrite(fid,sprintf('\n'));
    % 生成AM-DSB调制信号
    dsbSymbols = randn(1, round(dsbDuration*symbolRateDSB));
    dsbSymbols = ammod(dsbSymbols,1e6,sampleRate);
    dsbSymbolsFromSample = kron(dsbSymbols, ones(1, samplePerSymbolDSB));
    dsbSignal = zeros(1, length(time));
    dsbSignal(time >= dsbStart & time < dsbStart+dsbDuration) = dsbSymbolsFromSample .* exp(j*2*pi*(dsbCenterFreq)*time(time >= dsbStart & time < dsbStart+dsbDuration));

    Signal=Signal+dsbSignal;

    % 计算AM-DSB带宽
    bandwidth = 2 * symbolRateDSB;

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', 'AM-DSB',...
        'Start', dsbStart,...
        'Duration', dsbDuration,...
        'Freq', dsbCenterFreq,...
        'Rate', symbolRateDSB,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );


%     % 可视化结果
     %figure;
     %plot(time, real(dsbSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的AM-DSB信号样本');
end
%% 
% 生成AM-SSB信号
if ModTypeRandInd(8)==1
    ssbDuration =SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % SSB时长
    ssbStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); % SSB起始时间
    symbolRateSSB = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % SSB符号速率
    ssbCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % SSB中心频率
    samplePerSymbolSSB = round(sampleRate / symbolRateSSB); % 每个SSB符号中的采样点个数

%     把参入写入文件
    fwrite(fid,'AM-SSB');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([ssbStart ssbDuration ssbCenterFreq symbolRateSSB]));
    fwrite(fid,sprintf('\n'));
    % 生成AM-SSB调制信号
    ssbSymbols = randn(1, round(ssbDuration*symbolRateSSB));
    ssbSymbols = ssbmod(ssbSymbols,1e6,sampleRate);
    ssbSymbolsFromSample = kron(ssbSymbols, ones(1, samplePerSymbolSSB));
    ssbSignal = zeros(1, length(time));
    ssbSignal(time >= ssbStart & time < ssbStart+ssbDuration) = ssbSymbolsFromSample .* exp(j*2*pi*(ssbCenterFreq)*time(time >= ssbStart & time < ssbStart+ssbDuration));

    Signal=Signal+ssbSignal;

    % 计算AM-SSB带宽
    bandwidth = symbolRateSSB;

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', 'AM-SSB',...
        'Start', ssbStart,...
        'Duration', ssbDuration,...
        'Freq', ssbCenterFreq,...
        'Rate', symbolRateSSB,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );
   
%     % 可视化结果
     %figure;
     %plot(time, real(ssbSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的AM-SSB信号样本');
end
%% 
% 生成MSK信号
if ModTypeRandInd(9)==1
    mskDuration =SymbolDurationSet(randi([1 length(SymbolDurationSet)],1)); % MSK时长
    mskStart = SymbolStartTime(randi([1 length(SymbolStartTime)],1)); % MSK起始时间
    symbolRateMSK = SymbolRateSet(randi([1 length(SymbolRateSet)],1)); % MSK符号速率
    mskCenterFreq = EquCentFreq(randi([1 length(EquCentFreq)],1)); % MSK中心频率
    samplePerSymbolMSK = round(sampleRate / symbolRateMSK); % 每个MSK符号中的采样点个数

%     把参入写入文件
    fwrite(fid,'MSK');
    fwrite(fid,sprintf('\t'));
    fwrite(fid,num2str([mskStart mskDuration mskCenterFreq symbolRateMSK]));
    fwrite(fid,sprintf('\n'));
    % 生成MSK调制信号
    mskSymbols = randi([0 1],1,round(mskDuration*symbolRateMSK));
    mskSymbolsFromSample = mskmod(mskSymbols,samplePerSymbolMSK,[],pi/2);
    mskSymbolsFromSample=filter(MyRcos,1,mskSymbolsFromSample);
    mskSymbolsFromSample=mskSymbolsFromSample./max(abs(mskSymbolsFromSample)); % 调整数值，否则和模拟信号的差别太大
    
    mskSignal = zeros(1, length(time));
    mskSignal(time >= mskStart & time < mskStart+mskDuration) = mskSymbolsFromSample .* exp(j*2*pi*(mskCenterFreq)*time(time >= mskStart & time < mskStart+mskDuration));

    Signal=Signal+mskSignal;

    % 计算MSK带宽（理论公式）
    bandwidth = symbolRateMSK * 1.5;  % 理论带宽为符号速率的1.5倍

    % --- MODIFIED: 记录激活信号参数到结构体数组中 ---
    activatedSignals(end+1) = struct(...
        'Type', 'MSK',...
        'Start', mskStart,...
        'Duration', mskDuration,...
        'Freq', mskCenterFreq,...
        'Rate', symbolRateMSK,...
        'Bandwidth', bandwidth... % 新增带宽字段
    );

  
%     % 可视化结果
     %figure;
     %plot(time, real(mskSignal));
     %xlabel('时间 (秒)');
     %ylabel('实部');
     %title('生成的MSK信号样本');
end

% 如果需要增加噪声，可以在这里增加

Noise = wgn(1,length(Signal),0,'complex');

SignalWithNoise=Signal+Noise;

%  这里要先把时频图存下来，归一化之后，再通过cmap，ind2rgb,imwrite函数把矩阵转为表示彩色图像的3维矩阵。
TemptFT=pspectrum(SignalWithNoise,sampleRate,'spectrogram',TimeResolution=0.01);  % 这里注意矩阵的长和宽，其中1维对应频谱，2维对应时间。
TemptFT=pow2db(TemptFT);
FTSignal=TemptFT-min(min(TemptFT));
FTSignal=FTSignal./max(max(FTSignal));
% 彩色映射
TemptImage = ind2rgb(uint8(FTSignal * 255), cmap);
rgbImage = imresize(TemptImage, [512, 512]);
% 写图像文件
Imagename = sprintf('C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/ImageOfSigAndNoise/Signal_%d.jpg', SampleNumIter);
imwrite(flipud(rgbImage), Imagename);

% --- MODIFIED: 基于方案一的改进多类别语义分割标签生成 ---
% 使用无噪信号生成时频矩阵
[TemptSig, freqs, times] = pspectrum(Signal, sampleRate, 'spectrogram', TimeResolution=0.01);
TemptSig_dB = pow2db(TemptSig);

% === 安全的归一化处理 ===
% 检查是否包含无效值
if any(isnan(TemptSig_dB(:))) || any(isinf(TemptSig_dB(:)))
    fprintf('警告：时频图包含无效值，进行清理\n');
    TemptSig_dB(isnan(TemptSig_dB)) = -100;  % 将NaN替换为很小的dB值
    TemptSig_dB(isinf(TemptSig_dB)) = -100;  % 将Inf替换为很小的dB值
end

% 安全的归一化
minVal = min(TemptSig_dB(:));
maxVal = max(TemptSig_dB(:));

if maxVal == minVal
    % 如果最大值等于最小值（常数信号），设置为全零
    fprintf('警告：时频图为常数，设置为全零\n');
    FTSignal_normalized = zeros(size(TemptSig_dB));
else
    % 正常归一化
    FTSignal_normalized = (TemptSig_dB - minVal) / (maxVal - minVal);
end

% 最终检查
if any(isnan(FTSignal_normalized(:))) || any(isinf(FTSignal_normalized(:)))
    fprintf('错误：归一化后仍包含无效值，使用零矩阵\n');
    FTSignal_normalized = zeros(size(TemptSig_dB));
end

% 初始化标签矩阵（对应时频图尺寸）
[rows, cols] = size(TemptSig);
labelMatrix = zeros(rows, cols, 'uint8');

% 方案一：基于能量阈值的混合标注法
% 设置能量阈值参数
energyThreshold = 0.1;  % 降低能量阈值，原来0.3太高
boundaryExpansion = 3;  % 增加边界扩展像素数
minRegionSize = 2;      % 减小最小区域大小
adaptiveThreshold = true; % 启用自适应阈值

% 计算频率和时间分辨率
freqRes = freqs(2) - freqs(1);
timeRes = times(2) - times(1);
minFreq = freqs(1);
maxFreq = freqs(end);

% 遍历所有激活的信号并标注类别
for sigIdx = 1:length(activatedSignals)
    sig = activatedSignals(sigIdx);
    
    % === 步骤1：理论区域计算 ===
    % 时间坐标转换
    tStart = sig.Start;
    tEnd = tStart + sig.Duration;
    tEnd = min(tEnd, duration);  % 确保不超过信号总时长
    
    % 计算理论时间索引
    colStart_theory = max(1, round((tStart - times(1)) / timeRes) + 1);
    colEnd_theory = min(cols, round((tEnd - times(1)) / timeRes) + 1);
    
    % 频率坐标转换（考虑频谱泄露）
    bandwidth = sig.Bandwidth;
    fCenter = sig.Freq;
    % 扩展频率范围以考虑频谱泄露
    fLow = max(minFreq, fCenter - bandwidth/2 * 1.2);  % 扩展20%
    fHigh = min(maxFreq, fCenter + bandwidth/2 * 1.2);
    
    % 计算理论频率索引
    rowStart_theory = max(1, round((fLow - minFreq) / freqRes) + 1);
    rowEnd_theory = min(rows, round((fHigh - minFreq) / freqRes) + 1);
    
    % === 步骤2：能量阈值检测 ===
    % 在理论区域周围扩展搜索范围
    searchRowStart = max(1, rowStart_theory - boundaryExpansion);
    searchRowEnd = min(rows, rowEnd_theory + boundaryExpansion);
    searchColStart = max(1, colStart_theory - boundaryExpansion);
    searchColEnd = min(cols, colEnd_theory + boundaryExpansion);
    
    % === 边界和有效性检查 ===
    % 确保搜索区域有效
    if searchRowStart > searchRowEnd || searchColStart > searchColEnd
        fprintf('警告：信号 %s 搜索区域无效 - 行:[%d,%d], 列:[%d,%d]\n', ...
                sig.Type, searchRowStart, searchRowEnd, searchColStart, searchColEnd);
        % 使用理论区域作为备用
        searchRowStart = rowStart_theory;
        searchRowEnd = rowEnd_theory;
        searchColStart = colStart_theory;
        searchColEnd = colEnd_theory;
    end
    
    % 提取搜索区域的能量
    try
        searchRegion = FTSignal_normalized(searchRowStart:searchRowEnd, searchColStart:searchColEnd);
        
        % 检查搜索区域是否为空或包含NaN
        if isempty(searchRegion)
            fprintf('警告：信号 %s 搜索区域为空\n', sig.Type);
            % 跳到理论区域标注
            classID = ModClassMap(sig.Type);
            if rowStart_theory <= rowEnd_theory && colStart_theory <= colEnd_theory
                labelMatrix(rowStart_theory:rowEnd_theory, colStart_theory:colEnd_theory) = classID;
            end
            continue;
        end
        
        % 处理NaN值
        if any(isnan(searchRegion(:)))
            fprintf('警告：信号 %s 搜索区域包含NaN值，进行清理\n', sig.Type);
            searchRegion(isnan(searchRegion)) = 0;  % 将NaN替换为0
        end
        
    catch ME
        fprintf('错误：信号 %s 搜索区域提取失败 - %s\n', sig.Type, ME.message);
        % 使用理论区域作为备用
        classID = ModClassMap(sig.Type);
        if rowStart_theory <= rowEnd_theory && colStart_theory <= colEnd_theory
            labelMatrix(rowStart_theory:rowEnd_theory, colStart_theory:colEnd_theory) = classID;
        end
        continue;
    end
    
    % === 改进的能量检测策略 ===
    % 计算搜索区域的统计信息
    regionMax = max(searchRegion(:));
    regionMean = mean(searchRegion(:));
    regionStd = std(searchRegion(:));
    
    % 检查统计值的有效性
    if isnan(regionMax) || isnan(regionMean) || isnan(regionStd)
        fprintf('警告：信号 %s 统计值包含NaN - Max:%.3f, Mean:%.3f, Std:%.3f\n', ...
                sig.Type, regionMax, regionMean, regionStd);
        % 使用理论区域作为备用
        classID = ModClassMap(sig.Type);
        if rowStart_theory <= rowEnd_theory && colStart_theory <= colEnd_theory
            labelMatrix(rowStart_theory:rowEnd_theory, colStart_theory:colEnd_theory) = classID;
        end
        continue;
    end
    
    % 自适应阈值计算
    if adaptiveThreshold
        % 方法1：基于区域最大值的相对阈值
        adaptiveThresh1 = regionMax * 0.3;  % 最大值的30%
        % 方法2：基于均值+标准差的阈值
        adaptiveThresh2 = regionMean + 1.5 * regionStd;
        % 方法3：基于百分位数的阈值
        adaptiveThresh3 = prctile(searchRegion(:), 85);  % 85百分位数
        
        % 选择最适合的阈值（取中位数避免极端值）
        thresholds = [adaptiveThresh1, adaptiveThresh2, adaptiveThresh3, energyThreshold];
        currentThreshold = median(thresholds);
        
        % 调试信息
        fprintf('信号 %s: 区域统计 - Max:%.3f, Mean:%.3f, Std:%.3f\n', sig.Type, regionMax, regionMean, regionStd);
        fprintf('  阈值选择 - 自适应1:%.3f, 自适应2:%.3f, 自适应3:%.3f, 固定:%.3f, 最终:%.3f\n', ...
                adaptiveThresh1, adaptiveThresh2, adaptiveThresh3, energyThreshold, currentThreshold);
    else
        currentThreshold = energyThreshold;
    end
    
    % 应用能量阈值
    energyMask = searchRegion > currentThreshold;
    
    % 如果自适应阈值仍然失败，尝试更低的阈值
    if sum(energyMask(:)) == 0 && adaptiveThreshold
        fprintf('  自适应阈值失败，尝试更低阈值\n');
        lowerThreshold = min(regionMean + 0.5 * regionStd, regionMax * 0.15);
        energyMask = searchRegion > lowerThreshold;
        fprintf('  使用更低阈值:%.3f, 检测到像素数:%d\n', lowerThreshold, sum(energyMask(:)));
    end
    
    % === 步骤3：形态学处理 ===
    if sum(energyMask(:)) > 0
        % 去除小的噪声区域
        energyMask = bwareaopen(energyMask, minRegionSize);
        
        % 填充小的空洞
        energyMask = imfill(energyMask, 'holes');
        
        % 轻微的形态学闭运算，连接邻近区域
        se = strel('disk', 1);
        energyMask = imclose(energyMask, se);
    end
    
    % === 步骤4：混合标注策略 ===
    classID = ModClassMap(sig.Type);
    
    % 如果能量检测到有效区域，使用检测结果
    if sum(energyMask(:)) > 0
        fprintf('信号 %s: 能量检测成功，检测到 %d 个像素\n', sig.Type, sum(energyMask(:)));
        % 将局部坐标转换为全局坐标
        [maskRows, maskCols] = find(energyMask);
        globalRows = maskRows + searchRowStart - 1;
        globalCols = maskCols + searchColStart - 1;
        
        % 确保索引在有效范围内
        validIdx = globalRows >= 1 & globalRows <= rows & globalCols >= 1 & globalCols <= cols;
        globalRows = globalRows(validIdx);
        globalCols = globalCols(validIdx);
        
        % 标注检测到的区域
        for i = 1:length(globalRows)
            labelMatrix(globalRows(i), globalCols(i)) = classID;
        end
    else
        % 如果能量检测失败，回退到理论区域（缩小范围）
        fprintf('警告：信号 %s 能量检测失败，使用理论区域\n', sig.Type);
        
        % 使用更保守的理论区域
        rowStart_fallback = max(1, round(rowStart_theory + (rowEnd_theory - rowStart_theory) * 0.1));
        rowEnd_fallback = min(rows, round(rowEnd_theory - (rowEnd_theory - rowStart_theory) * 0.1));
        colStart_fallback = max(1, round(colStart_theory + (colEnd_theory - colStart_theory) * 0.1));
        colEnd_fallback = min(cols, round(colEnd_theory - (colEnd_theory - colStart_theory) * 0.1));
        
        if rowStart_fallback <= rowEnd_fallback && colStart_fallback <= colEnd_fallback
            labelMatrix(rowStart_fallback:rowEnd_fallback, colStart_fallback:colEnd_fallback) = classID;
        end
    end
end

% === 步骤5：后处理优化 ===
% 去除孤立的像素点
labelMatrix_cleaned = labelMatrix;
for classID = 1:9
    classMask = (labelMatrix == classID);
    classMask_cleaned = bwareaopen(classMask, 3);  % 去除小于3像素的区域
    labelMatrix_cleaned(classMask & ~classMask_cleaned) = 0;
end
labelMatrix = labelMatrix_cleaned;

% 调整尺寸并保存
labelMatrix = imresize(labelMatrix, [512 512], 'nearest'); % 保持整数类别
Labelname = sprintf('C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/ImageOfSig/Signal_%d.png', SampleNumIter);
imwrite(flipud(labelMatrix), Labelname);
% --- MODIFIED: 调试时验证标签与输入对齐 ---
%figure;
%subplot(1,2,1); imshow(imread(Imagename)); title('输入含噪时频图');
%subplot(1,2,2); imshow(label2rgb(labelMatrix)); title('生成的多类别标签');
% 在生成标签后调用
%validate_labels(activatedSignals, Signal, sampleRate, SymbolRateSet);



% 这里要先把时频图存下来，归一化之后，再通过cmap，ind2rgb,imwrite函数把矩阵转为表示彩色图像的3维矩阵。
TemptFT=pspectrum(Noise,sampleRate,'spectrogram',TimeResolution=0.01);  % 这里注意矩阵的长和宽，其中1维对应频谱，2维对应时间。
TemptFT=pow2db(TemptFT);
FTSignal=TemptFT-min(min(TemptFT));
FTSignal=FTSignal./max(max(FTSignal));
%% 彩色映射
%TemptImage = ind2rgb(uint8(FTSignal * 255), cmap);
%rgbImage = imresize(TemptImage, [512, 512]);
%Labelname = sprintf('C:/Users/Pius/Desktop/MyTry/MyTry/MyDataSet/ImageOfNoise/Signal_%d.png', SampleNumIter);
%imwrite(flipud(rgbImage), Labelname);

% 保存参数标签文件（CSV格式）
    if ~isempty(activatedSignals)
        paramsTable = struct2table(activatedSignals);
        paramsTable.SampleID = repmat(SampleNumIter, height(paramsTable), 1);
        paramFilename = fullfile(paramDir, sprintf('Signal_%d.csv', SampleNumIter));
        writetable(paramsTable, paramFilename);
    end

% % 写信号文件
 %Signalname = sprintf('C:/software/MyTry-Liu/signals/Signal_%d.mat', SampleNumIter);
 %save(Signalname,'Signal')
end

fclose(fid);


