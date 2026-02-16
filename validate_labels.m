function validate_labels(activatedSignals, Signal, sampleRate, SymbolRateSet)
    % 执行上述所有验证步骤（字段检查、时间重叠、统计验证等）
    % 发现错误时通过 error() 抛出具体信息
    % ------ 在所有标签生成后添加以下代码 ------
    disp('===== 当前所有激活信号标签 =====');
    for sigIdx = 1:length(activatedSignals)
        sig = activatedSignals(sigIdx);
        fprintf('[信号%d] 类型: %s | 起始时间: %.2fs | 时长: %.2fs | 中心频率: %.1fHz | 符号率: %d sps\n', ...
            sigIdx, sig.Type, sig.Start, sig.Duration, sig.Freq, sig.Rate);
    end

    
    % --- 检查字段是否匹配初始化定义 ---
    expectedFields = {'Type';'Start';'Duration';'Freq';'Rate'};
    for sigIdx = 1:length(activatedSignals)
        actualFields = fieldnames(activatedSignals(sigIdx));
        if ~isequal(actualFields, expectedFields)
            error('[结构体检错] 信号 %d 字段缺失或冗余。预期字段：%s，实际字段：%s', ...
                sigIdx, strjoin(expectedFields, ', '), strjoin(actualFields, ', '));
        end
    end
    disp('✅ 所有标签字段一致性验证通过');

    % 步骤2: 参数合法性检查
    % ...（代码见步骤6）...
    % --- 验证符号率是否来自SymbolRateSet ---
    symbolRatesInLabels = [activatedSignals.Rate];
    invalidSymbolRates = setdiff(symbolRatesInLabels, SymbolRateSet);
    if ~isempty(invalidSymbolRates)
        error('发现未定义的符号率: %s', mat2str(invalidSymbolRates));
    else
        disp('✅ 所有符号率均来自预定义集合');
    end

% 对CenterFreq等其他参数执行类似检查

    
    % 步骤3: 时频图生成（可选）
    % ...（代码见步骤4）...
    % ------ 时频图与标签叠加示例 ------
    figure;
    spectrogram(Signal, 256, 250, 512, sampleRate, 'yaxis'); % 生成原始信号的时频图
    hold on;
    
    % 标记所有信号的时间区间
        for sigIdx = 1:length(activatedSignals)
            sig = activatedSignals(sigIdx);
            startTime = sig.StartTime;
            endTime = startTime + sig.Duration;
            
            % 在时频图上用矩形标记信号位置
            rectangle('Position', [startTime, sig.CenterFreq - 1e3, endTime - startTime, 2e3], ...
                      'EdgeColor', 'r', 'LineWidth', 1.5, 'LineStyle', '--');
            text(startTime, sig.CenterFreq + 2e3, sig.Type, ...
                 'Color', 'w', 'FontSize', 10, 'FontWeight', 'bold');
        end
    
        title('信号时频分布与标签对齐验证');
        xlabel('时间 (s)');
        ylabel('频率 (Hz)');

    
    disp('✅ 所有标签验证通过');
end
