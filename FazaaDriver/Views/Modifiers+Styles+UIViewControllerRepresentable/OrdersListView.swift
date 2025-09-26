//
//  OrdersListView.swift
//  Fazaa
//
//  Created by Assistant on 25.09.2025.
//

import SwiftUI
import SkeletonUI

struct OrdersListView: View {
    @StateObject private var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @State private var selectedFilter: OrderStatusFilter = .all
    @State private var isRefreshing = false
    private let pageLimit = 20
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                
                VStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.orders.isEmpty {
                        skeletonList
                    } else if viewModel.orders.isEmpty {
                        Text(LocalizedStringKey.noOrdersFound)
                            .customFont(weight: .regular, size: 14)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.orders, id: \.self) { order in
                                NavigationLink {
                                    if let id = order.id {
                                        // المعامل الصحيح حسب OrderDetailsView الحالية
                                        OrderDetailsView(orderID: id)
                                    } else {
                                        Text(LocalizedStringKey.orderDetails)
                                            .customFont(weight: .semiBold, size: 16)
                                    }
                                } label: {
                                    OrderRow(order: order)
                                }
                                .onAppear {
                                    if order == viewModel.orders.last {
                                        viewModel.loadMoreOrders(status: selectedFilter.statusParam, limit: pageLimit)
                                    }
                                }
                            }
                            
                            if viewModel.isFetchingMoreData && viewModel.currentPage < viewModel.totalPages {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding(.vertical, 12)
                                    Spacer()
                                }
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            refresh()
                        }
                    }
                }
            }
            .navigationTitle(LocalizedStringKey.myOrders)
            .onAppear {
                if viewModel.orders.isEmpty {
                    viewModel.getOrders(status: selectedFilter.statusParam, page: 1, limit: pageLimit)
                }
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OrderStatusFilter.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                        viewModel.refreshOrders(status: filter.statusParam, limit: pageLimit)
                    } label: {
                        Text(filter.title)
                            .customFont(weight: .semiBold, size: 14)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(filter == selectedFilter ? Color.blue.opacity(0.12) : Color.gray.opacity(0.1))
                            .foregroundColor(filter == selectedFilter ? .blue : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(UIColor.systemBackground))
    }
    
    private var skeletonList: some View {
        List {
            ForEach(0..<6, id: \.self) { _ in
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 48, height: 48)
                        .skeleton(with: true, shape: .rectangle)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)
                            .skeleton(with: true, shape: .rectangle)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 150, height: 10)
                            .skeleton(with: true, shape: .rectangle)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.plain)
        .disabled(true)
    }
    
    private func refresh() {
        isRefreshing = true
        viewModel.refreshOrders(status: selectedFilter.statusParam, limit: pageLimit)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            isRefreshing = false
        }
    }
}

private enum OrderStatusFilter: CaseIterable, Hashable {
    case all, new, accepted, started, way, progress, updated, prefinished, finished, canceled
    
    var statusParam: String? {
        switch self {
        case .all: return nil
        case .new: return "new"
        case .accepted: return "accepted"
        case .started: return "started"
        case .way: return "way"
        case .progress: return "progress"
        case .updated: return "updated"
        case .prefinished: return "prefinished"
        case .finished: return "finished"
        case .canceled: return "canceled"
        }
    }
    
    var title: String {
        switch self {
        case .all: return LocalizedStringKey.all
        case .new: return OrderStatus.new.displayTitle
        case .accepted: return OrderStatus.accepted.displayTitle
        case .started: return OrderStatus.started.displayTitle
        case .way: return OrderStatus.way.displayTitle
        case .progress: return OrderStatus.progress.displayTitle
        case .updated: return OrderStatus.updated.displayTitle
        case .prefinished: return OrderStatus.prefinished.displayTitle
        case .finished: return OrderStatus.finished.displayTitle
        case .canceled: return OrderStatus.canceled.displayTitle
        }
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(order.orderStatus.colors.background)
                Image(order.orderStatus.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundColor(order.orderStatus.colors.foreground)
            }
            .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(order.title ?? LocalizedStringKey.orderDetails)
                        .customFont(weight: .semiBold, size: 16)
                        .lineLimit(1)
                    Spacer()
                    Text("#\(order.orderNo ?? "")")
                        .customFont(weight: .medium, size: 13)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text(order.orderStatus.displayTitle)
                        .customFont(weight: .semiBold, size: 12)
                        .foregroundColor(order.orderStatus.colors.foreground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(order.orderStatus.colors.background)
                        .clipShape(Capsule())
                    
                    if let date = order.dtDate, !date.isEmpty {
                        Text(date)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.secondary)
                    }
                    if let time = order.dtTime, !time.isEmpty {
                        Text(time)
                            .customFont(weight: .regular, size: 12)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let address = order.address?.address, !address.isEmpty {
                    Text(address)
                        .customFont(weight: .regular, size: 12)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    OrdersListView()
}
