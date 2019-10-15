//
//  String+Validation.swift
//  Any
//
//  Created by ZJaDe on 2018/6/19.
//  Copyright © 2018年 ZJaDe. All rights reserved.
//

import Foundation

extension String {
    public var isEmail: Bool {
        let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: count))
        return (firstMatch?.range.location != NSNotFound && firstMatch?.url?.scheme == "mailto")
    }
    public var isNumber: Bool {
        return NumberFormatter().number(from: self) != nil
    }
    /// ZJaDe: 是否包含 Emoji
    public var includesEmoji: Bool {
        for i in 0...count {
            let c: unichar = (self as NSString).character(at: i)
            if (0xD800 <= c && c <= 0xDBFF) || (0xDC00 <= c && c <= 0xDFFF) {
                return true
            }
        }
        return false
    }
    /// 验证日期是否合法
    public var isValidateDate: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.date(from: self) != nil
    }
}
// MARK: - NSPredicate
extension String {
    public func isValidate(by regex: String) -> Bool {
        // swiftlint:disable force_try
        return try! Regex(regex).test(testStr: self)
//        let pre = NSPredicate(format: "SELF MATCHES %@", regex)
//        return pre.evaluate(with: self)
    }
    /// ZJaDe: 是否可以转换成数字
    public var isPureInt: Bool {
        let scan = Scanner(string: self)
        var val: Int = 0
        return scan.scanInt(&val)
    }
    /// ZJaDe: 是否全是小写字母
    public var isLowercase: Bool {
        let regex = "^[a-z]+$"
        return self.isValidate(by: regex)
    }
    /// ZJaDe: 是否全是大写字母
    public var isCapitalized: Bool {
        let regex = "^[A-Z]+$"
        return self.isValidate(by: regex)
    }
    /// ZJaDe: 是否是价格
    public var isPrice: Bool {
        let regex = "^\\d*\\.?\\d{0,2}$"
        return self.isValidate(by: regex)
    }
}
// MARK: - Regex
extension String {
    /// syk: 是否是手机号
    public var isMobilePhone: Bool {
        var result: Bool = false
        if self.isValidate(by: "^(1[0-9][0-9])[0-9]{8}$") {
            result = true
        }
        return result
    }
    /// syk: 是否是验证码
    public var isCode: Bool {
        var result: Bool = false
        if self.isValidate(by: "^[0-9]{6}$") {
            result = true
        }
        return result
    }
    /// syk: 判断名字是否正确
    public var isTrueName: Bool {
        return self.isValidate(by: "^[\\u4e00-\\u9fa5]{2,}$")
    }
    /// syk: 判断是否含有中文
    public var isContainChinese: Bool {
        return self.isValidate(by: "^.*[\\u4e00-\\u9fa5].*$")
    }
    /// syk: 纯英文
    public var isPureEnglish: Bool {
        let regex = "^[a-zA-Z]+$"
        return self.isValidate(by: regex)
    }
    /// syk: 纯英文或者纯数字
    public var isPureEnglishOrInt: Bool {
        let regex = "^[a-zA-Z]+$|^[0-9]+$"
        return self.isValidate(by: regex)
    }
}

// MARK: - Others
extension String {
    //判断是否为有效银行卡号
    public var isValidBankCard: Bool {
        /// ZJaDe: 判断是不是数字
        guard self.isNumber else {
            return false
        }
        /// ZJaDe: 判断位数对不对
        let numberLength = self.count
        guard numberLength >= 13 && numberLength <= 19 else {
            return false
        }
        /// ZJaDe: 反转并转换成数字数组
        guard let array = self.reversed().map({$0.wholeNumberValue}) as? [Int] else {
            return false
        }
        struct Result {
            var oddNumber: Int = 0 //奇数位和
            var evenNumber: Int = 0 //偶数位和
        }
        /// ZJaDe: 数组从1开始计数，奇数位累加到oddNumber, 偶数位累加到evenNumber
        let result: Result = array.lazy.enumerated().reduce(into: .init()) { (result, arg1) in
            var (offSet, element) = arg1
            if (offSet + 1) % 2 == 0 {
                element *= 2
                if element >= 10 {
                    element -= 9
                }
                result.evenNumber += element
            } else {
                result.oddNumber += element
            }
        }
        return (result.oddNumber + result.evenNumber) % 10 == 0
    }
}
extension String {
    /// 判断输入是否为身份证号码
    public var isIdentificationNo: Bool {
        var result: Bool = false
        if self.isValidate(by: "^[0-9]{15}$|^[0-9]{18}$|^[0-9]{17}([0-9]|X|x)$") && calculateIdentificationNo {
            result = true
        }
        return result
    }
    subscript (r: Range<Int>) -> Substring {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return self[start..<end]
    }
    private var calculateIdentificationNo: Bool {
        let count = self.count
        if count == 15 {
            return ("19" + self[6..<12]).isValidateDate
        }
        guard count == 18 else {
            return false
        }
        guard String(self[6..<14]).isValidateDate else {
            return false
        }
        //将前17位加权因子保存在数组里
        let weightingCoefficient = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        //这是除以11后，可能产生的11位余数、验证码，也保存成数组
        let validateNums = ["1", "0", "x", "9", "8", "7", "6", "5", "4", "3", "2"]

        //用来保存前17位各自乖以加权因子后的总和 并 取余数计算出校验码所在数组的位置
        let remainder: Int = zip(weightingCoefficient, self).reduce(0) { (result, arg1) -> Int in
            let (num, char) = arg1
            return result + (char.wholeNumberValue ?? 0) * num
        } % 11
        //得到最后一位身份证号码 校验
        return validateNums[remainder] == self.last!.lowercased()
    }
}
