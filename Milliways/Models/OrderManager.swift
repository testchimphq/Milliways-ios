//
//  OrderManager.swift
//  Milliways
//
//  Created by gilm on 05/11/2025.
//

import SwiftUI
import Combine

struct OrderItem: Identifiable {
    let id = UUID()
    let menuItem: MenuItem
    var quantity: Int

    var totalPrice: Double {
        Double(quantity) * menuItem.price
    }
}

class OrderManager: ObservableObject {
    @Published var items: [OrderItem] = []
    @Published var couponDiscount: Double = 0
    @Published var appliedCouponCode: String? = nil

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }

    // Coupon discount is frozen when applied — does not update if cart changes
    var finalTotal: Double {
        totalPrice - couponDiscount
    }

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    func addItem(_ item: MenuItem, quantity: Int) {
        items.append(OrderItem(menuItem: item, quantity: quantity))
    }

    func removeItem(at index: Int) {
        items.remove(at: index)
    }

    @discardableResult
    func applyCoupon(_ code: String) -> Bool {
        guard code.uppercased() == "MARVIN" else { return false }
        couponDiscount = 20.0
        appliedCouponCode = "MARVIN"
        return true
    }

    func clearOrder() {
        items.removeAll()
        couponDiscount = 0
        appliedCouponCode = nil
    }
}
