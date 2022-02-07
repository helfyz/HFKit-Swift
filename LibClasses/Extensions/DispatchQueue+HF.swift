//
//  DispatchQueue+HF.swift
//  HFKit
//
//  Created by helfy on 2021/12/30.
//
import Dispatch

extension DispatchQueue {
    static let hf = DispatchQueue(label: "com.hf.Queue",qos: .userInteractive, attributes: .concurrent)
}
