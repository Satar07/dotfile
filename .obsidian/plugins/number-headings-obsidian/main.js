'use strict';

var obsidian = require('obsidian');

function __awaiter(thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
}

// 基础工具函数
function getActiveView(app) {
    const activeView = app.workspace.getActiveViewOfType(obsidian.MarkdownView);
    return activeView !== null && activeView !== void 0 ? activeView : undefined;
}

function isViewActive(app) {
    const activeView = getActiveView(app);
    return !!(activeView && activeView.file);
}

function getViewInfo(app) {
    const activeView = getActiveView(app);
    if (!activeView || !activeView.file) return undefined;
    
    const data = app.metadataCache.getFileCache(activeView.file) || {};
    const editor = activeView.editor;
    
    if (activeView && data && editor) {
        return { activeView, data, editor };
    }
    return undefined;
}

// 添加大写和小写字母转换函数
function numberToUpperLetter(num) {
    let result = '';
    while (num > 0) {
        num--;
        result = String.fromCharCode(65 + (num % 26)) + result; // 65 是大写 'A' 的 ASCII 码
        num = Math.floor(num / 26);
    }
    return result;
}

function numberToLowerLetter(num) {
    let result = '';
    while (num > 0) {
        num--;
        result = String.fromCharCode(97 + (num % 26)) + result; // 97 是小写 'a' 的 ASCII 码
        num = Math.floor(num / 26);
    }
    return result;
}

// 罗马数字转换
function numberToRoman(num) {
    const romanNumerals = [
        { value: 1000, symbol: 'M' },
        { value: 900, symbol: 'CM' },
        { value: 500, symbol: 'D' },
        { value: 400, symbol: 'CD' },
        { value: 100, symbol: 'C' },
        { value: 90, symbol: 'XC' },
        { value: 50, symbol: 'L' },
        { value: 40, symbol: 'XL' },
        { value: 10, symbol: 'X' },
        { value: 9, symbol: 'IX' },
        { value: 5, symbol: 'V' },
        { value: 4, symbol: 'IV' },
        { value: 1, symbol: 'I' }
    ];
    
    let result = '';
    for (let i = 0; i < romanNumerals.length; i++) {
        while (num >= romanNumerals[i].value) {
            result += romanNumerals[i].symbol;
            num -= romanNumerals[i].value;
        }
    }
    return result;
}

// 编号转换函数
function convertNumber(num, style, isTopLevel) {
    switch (style) {
        case '1': return num.toString();
        case 'A': return isTopLevel ? numberToUpperLetter(num) : numberToLowerLetter(num);
        case 'I': return numberToRoman(num);
        default: return num.toString();
    }
}

// 编号生成逻辑
function generateNumbering(numbers, level, settings) {
    const parts = [];
    // 【修改点】: 解析 styleLevel1 设置
    const style = settings.styleLevel1;
    const useChapter = style.endsWith('_chapter');
    const baseStyle = useChapter ? style.split('_')[0] : style;

    // H2 级别的数字字符串
    const h2NumStr = convertNumber(numbers[0], baseStyle, true);

    if (level === 0) {
        // 仅 H2 ("第 1 章" 或 "1")
        if (useChapter) {
            parts.push(`第 ${h2NumStr} 章`);
        } else {
            parts.push(h2NumStr);
        }
    } else {
        // H3+ ("1.1", "1.1.1"...)
        // H2 部分 (总是基础数字, 不带 "第 X 章")
        parts.push(convertNumber(numbers[0], baseStyle, true));
        // H3+ 部分
        for (let i = 1; i <= level; i++) {
            parts.push(convertNumber(numbers[i], settings.styleLevelOther, false));
        }
    }
    return parts.join('.');
}

// 优化后的标题清理函数
function cleanHeadingText(text) {
    const trimmedText = text.trim();

    // 修改后的日期时间格式检查: 检查是否以日期时间开头
    const dateTimePrefixRegex = /^(\d{4}年\d{1,2}月\d{1,2}日(?:\s+\d{1,2}:\d{1,2}(?::\d{1,2})?)?\s*)/;
    const match = trimmedText.match(dateTimePrefixRegex);

    let prefix = '';
    let textToClean = trimmedText;

    if (match) {
        prefix = match[1]; // 提取日期时间前缀
        textToClean = trimmedText.substring(prefix.length).trim(); // 获取需要清理的剩余部分
        // 如果清理后剩余部分为空，直接返回前缀
        if (textToClean === '') {
            return prefix.trim();
        }
    } else {
        // 如果文本很短或没有特殊字符（且不含日期前缀），直接返回
        if (text.length < 3) return text;
    }

    // 如果在提取日期前缀后，剩余文本为空，则无需继续清理
    if (match && textToClean === '') {
        return prefix.trim();
    }

    // 创建一个正则表达式数组，避免重复创建
    const patterns = [
        /\*\*/g,                                          // 加粗
        /[\u{1F300}-\u{1F9FF}\u{2000}-\u{2BFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{FE00}-\u{FE0F}]/gu,  // 表情
        /^\s*\([^)]*\)\s*/,                              // 括号 (应用于 textToClean 的开头)
        /^\s*\d+(?:\.\d+)*\.?\s*/,                       // 阿拉伯数字 (应用于 textToClean 的开头)
        /^\s*[一二三四五六七八九十百千万]+[、.]\s*/,      // 中文数字 (应用于 textToClean 的开头)
        /^\s*[ⅠⅡⅢⅣⅤⅥⅦⅧⅨⅩ]+[、.]\s*/,                  // 罗马数字 (应用于 textToClean 的开头)
        /`/g,                                            // 代码格式
        /\s{2,}/g,                                       // 多余空格
        /^\s*[\d.]+\s*[:：]\s*/,                         // 数字后面的冒号 (应用于 textToClean 的开头)
        /^\s*[:：]\s*/,                                  // 开头的冒号 (应用于 textToClean 的开头)
        /\s*[:：]\s*/                                    // 任意位置的冒号
    ];

    // 对 textToClean 应用清理规则
    let cleanedText = textToClean;
    let changed;

    // 最多循环3次，避免死循环
    for (let i = 0; i < 3; i++) {
        changed = false;
        const originalLength = cleanedText.length;

        // 应用所有清理模式
        for (const pattern of patterns) {
            const newText = cleanedText.replace(pattern, '');
            if (newText !== cleanedText) {
                cleanedText = newText;
                changed = true;
            }
        }

        // 如果没有变化，提前退出
        if (!changed) break;
    }

    // 返回前缀 + 清理后的文本
    // 在拼接前确保 cleanedText 不是空的，避免 "prefix " 这样的结果
    const result = prefix + (cleanedText.trim() === '' ? '' : cleanedText.trim());
    return result.trim(); // 最后再 trim 一次
}

// 修改后的 updateHeadingNumbering 函数
function updateHeadingNumbering(viewInfo, settings) {
    if (!viewInfo) return;
    
    // 【修改点 1】: 过滤掉 H1 标题，只处理 H2 及更深级别的标题
    const headings = (viewInfo.data.headings ?? []).filter(h => h.level >= 2);
    
    if (headings.length === 0) return;
    
    const editor = viewInfo.editor;
    // minLevel 现在会自动从 H2 或文档中存在的 H2 以下的最小级别开始
    const minLevel = Math.min(...headings.map(h => h.level)); 
    let currentNumbers = new Array(6).fill(0);
    const changes = [];
    let modifiedCount = 0;
    
    for (const heading of headings) {
        const level = heading.level;
        // relativeLevel 现在会以 H2 (或最小级别) 为 0 开始计算
        const relativeLevel = level - minLevel; 
        
        currentNumbers[relativeLevel]++;
        for (let i = relativeLevel + 1; i < 6; i++) {
            currentNumbers[i] = 0;
        }
        
        const numberParts = generateNumbering(
            currentNumbers.slice(0, relativeLevel + 1),
            relativeLevel,
            settings
        );
            
        const lineText = editor.getLine(heading.position.start.line);
        // 【修改点】: 更新 regex 以匹配 "第 1 章" 格式 或 "1" 格式
        const headingMatch = lineText.match(/^(\s{0,4}#{1,6})(\s+(?:(?:[A-Za-z0-9IVXLCDM]+\.)*[A-Za-z0-9IVXLCDM]+|第\s*[\dA-Za-zIVXLCDM]+\s*章)\s+|\s+)(.*)/);
        
        if (headingMatch) {
            const [, hashPart, existingSpace, restOfLine] = headingMatch;
            // 在这里应用格式化
            const cleanedText = cleanHeadingText(restOfLine);
            const newLine = `${hashPart} ${numberParts} ${cleanedText}`;
            
            if (lineText !== newLine) {
                changes.push({
                    from: { line: heading.position.start.line, ch: 0 },
                    to: { line: heading.position.start.line, ch: lineText.length },
                    text: newLine
                });
                modifiedCount++;
            }
        }
    }
    
    if (changes.length > 0) {
        editor.transaction({ changes });
        // 添加控制台日志
        console.log('标题编号插件: 更新了 ' + modifiedCount + ' 个标题 (H2 起始)');
        // 添加通知
        const fileName = viewInfo.activeView.file.basename;
        new obsidian.Notice(`已更新 ${fileName} 中的 ${modifiedCount} 个标题 (H2 起始)`);
    }
}

const DEFAULT_SETTINGS = {
    styleLevel1: '1_chapter', // 【修改点】: 默认为 "第 X 章" 格式
    styleLevelOther: '1',
    auto: false,
    off: false,
    refreshInterval: 10,    // 自动刷新间隔（秒）
    updateDelay: 1         // 编辑后更新延时（秒）
};

class NumberHeadingsPlugin extends obsidian.Plugin {
    constructor() {
        super(...arguments);
        this.settings = DEFAULT_SETTINGS;
        this.updateTimeout = null;
    }

    onload() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.loadSettings();
            
            // 添加编辑器变更事件监听器
            this.registerEvent(
                this.app.workspace.on('editor-change', (editor) => {
                    if (this.settings.auto && !this.settings.off) {
                        const viewInfo = getViewInfo(this.app);
                        if (viewInfo) {
                            // 使用防抖来避免频繁更新
                            if (this.updateTimeout) {
                                clearTimeout(this.updateTimeout);
                            }
                            this.updateTimeout = setTimeout(() => {
                                updateHeadingNumbering(viewInfo, this.settings);
                            }, this.settings.updateDelay * 1000);  // 转换为毫秒
                        }
                    }
                })
            );

            // 添加命令
            this.addCommand({
                id: 'number-headings',
                name: '对文档中的所有标题进行编号 (H2 起始)', // 修改了命令名称
                checkCallback: (checking) => {
                    if (checking) return isViewActive(this.app);
                    const viewInfo = getViewInfo(this.app);
                    if (viewInfo && !this.settings.off) {
                        updateHeadingNumbering(viewInfo, this.settings);
                    }
                    return false;
                }
            });

            this.addCommand({
                id: 'remove-number-headings',
                name: '删除文档中所有标题的编号 (H2 起始)', // 修改了命令名称
                checkCallback: (checking) => {
                    if (checking) return isViewActive(this.app);
                    const viewInfo = getViewInfo(this.app);
                    if (viewInfo) {
                        const changes = [];
                        // 【修改点 2】: 同样过滤掉 H1，只处理 H2 及更深级别
                        const headingsToClear = (viewInfo.data.headings ?? []).filter(h => h.level >= 2);
                        
                        for (const heading of headingsToClear) {
                            const lineText = viewInfo.editor.getLine(heading.position.start.line);
                            // 【修改点】: 更新 regex 以匹配 "第 1 章" 格式 或 "1" 格式
                            const match = lineText.match(/^(\s{0,4}#{1,6})(\s+(?:(?:[A-Za-z0-9IVXLCDM]+\.)*[A-Za-z0-9IVXLCDM]+|第\s*[\dA-Za-zIVXLCDM]+\s*章)\s+)/);
                            const headingStart = lineText.match(/^(\s{0,4}#{1,6})\s*/);
                            
                            if (match) {
                                changes.push({
                                    from: { 
                                        line: heading.position.start.line, 
                                        ch: headingStart[0].length 
                                    },
                                    to: { 
                                        line: heading.position.start.line, 
                                        ch: match[0].length 
                                    },
                                    text: ' '
                                });
                            }
                        }
                        if (changes.length > 0) {
                            viewInfo.editor.transaction({ changes });
                        }
                    }
                    return true;
                }
            });

            this.addSettingTab(new NumberHeadingsPluginSettingTab(this.app, this));

            // 注册自动编号定时器
            this.registerInterval(window.setInterval(() => {
                const viewInfo = getViewInfo(this.app);
                if (viewInfo && this.settings.auto && !this.settings.off) {
                    updateHeadingNumbering(viewInfo, this.settings);
                }
            }, this.settings.refreshInterval * 1000));
        });
    }

    onunload() {
        if (this.updateTimeout) {
            clearTimeout(this.updateTimeout);
        }
    }

    loadSettings() {
        return __awaiter(this, void 0, void 0, function* () {
            this.settings = Object.assign({}, DEFAULT_SETTINGS, yield this.loadData());
        });
    }

    saveSettings() {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.saveData(this.settings);
        });
    }
}

class NumberHeadingsPluginSettingTab extends obsidian.PluginSettingTab {
    constructor(app, plugin) {
        super(app, plugin);
        this.plugin = plugin;
    }

    display() {
        const { containerEl } = this;
        containerEl.empty();
        containerEl.createEl('h2', { text: '标题编号-设置' });
        
        // 添加一个说明，告知用户此版本从 H2 开始
        containerEl.createEl('p', { text: '注意：此插件版本已修改为从 H2 标题开始作为顶层编号。H1 标题将被忽略。' });
        // 【修改点】: 移除了关于 H2 格式的硬编码说明


        // 【修改点】: 替换了您选择的代码块，提供了更多选项
        new obsidian.Setting(containerEl)
            .setName('顶层标题样式 (H2)') // 调整了描述
            .setDesc('定义 H2 标题的编号样式。')
            .addDropdown(dropdown => dropdown
                .addOption('1', '数字 (1, 2, 3)')
                .addOption('A', '字母 (A, B, C)')
                .addOption('I', '罗马数字 (I, II, III)')
                .addOption('1_chapter', '章节 (第 1 章, 第 2 章)')
                .addOption('A_chapter', '章节 (第 A 章, 第 B 章)')
                .addOption('I_chapter', '章节 (第 I 章, 第 II 章)')
                .setValue(this.plugin.settings.styleLevel1)
                .onChange((value) => __awaiter(this, void 0, void 0, function* () {
                    this.plugin.settings.styleLevel1 = value;
                    yield this.plugin.saveSettings();
                })));

        new obsidian.Setting(containerEl)
            .setName('较低级别标题样式 (H3+)') // 调整了描述
            .setDesc('定义 H3 及更深级别标题的编号样式。有效值为：1（数字）、A（字母）或 I（罗马数字）')
            .addDropdown(dropdown => dropdown
                .addOption('1', '数字 (1, 2, 3)')
                .addOption('A', '字母 (a, b, c)')
                .addOption('I', '罗马数字 (I, II, III)')
                .setValue(this.plugin.settings.styleLevelOther)
                .onChange((value) => __awaiter(this, void 0, void 0, function* () {
                    this.plugin.settings.styleLevelOther = value;
                    yield this.plugin.saveSettings();
                })));

        new obsidian.Setting(containerEl)
            .setName('自动编号')
            .setDesc('开启文档的自动编号 (H2 起始)')
            .addToggle(toggle => toggle
                .setValue(this.plugin.settings.auto)
                .setTooltip('启用自动编号')
                .onChange((value) => __awaiter(this, void 0, void 0, function* () {
                    this.plugin.settings.auto = value;
                    yield this.plugin.saveSettings();
                })));

        new obsidian.Setting(containerEl)
            .setName('自动刷新间隔')
            .setDesc('自动编号的刷新间隔（秒）')
            .addSlider(slider => slider
                .setLimits(1, 60, 1)
                .setValue(this.plugin.settings.refreshInterval)
                .setDynamicTooltip()
                .onChange((value) => __awaiter(this, void 0, void 0, function* () {
                    this.plugin.settings.refreshInterval = value;
                    yield this.plugin.saveSettings();
                })));

        new obsidian.Setting(containerEl)
            .setName('编辑响应延时')
            .setDesc('编辑后更新编号的延时（秒）。较小的值响应更快，但可能会影响编辑体验。')
            .addSlider(slider => slider
                .setLimits(1, 60, 1)  // 范围改为1-60秒，步进值为1
                .setValue(this.plugin.settings.updateDelay)
                .setDynamicTooltip()
                .onChange((value) => __awaiter(this, void 0, void 0, function* () {
                    this.plugin.settings.updateDelay = value;
                    yield this.plugin.saveSettings();
                })));
    }
}

module.exports = NumberHeadingsPlugin;


