import SwiftUI

struct OrdersView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var orders: [Order] = []
    @State private var selectedOrder: Order?
    @State private var showingOrderDetail: Bool = false
    @State private var selectedStatusFilter: OrderStatus?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with Statistics
                headerView
                
                // Status Filter
                statusFilterView
                
                // Orders List
                ordersListView
            }
            .navigationTitle("Orders")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        loadOrders()
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $selectedOrder) { order in
            OrderDetailView(order: order)
                .environmentObject(cartViewModel)
        }
        .onAppear {
            loadOrders()
        }
        .refreshable {
            await loadOrdersAsync()
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 15) {
            // Statistics Cards
            HStack(spacing: 15) {
                StatCard(
                    title: "Total Orders",
                    value: "\(orders.count)",
                    icon: "bag.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Active Orders",
                    value: "\(orders.filter { $0.status != .delivered && $0.status != .cancelled }.count)",
                    icon: "clock.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(orders.filter { $0.status == .delivered }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Status Filter View
    private var statusFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                FilterChip(
                    title: "All",
                    isSelected: selectedStatusFilter == nil
                ) {
                    selectedStatusFilter = nil
                }
                
                ForEach(OrderStatus.allCases, id: \.self) { status in
                    FilterChip(
                        title: status.rawValue,
                        isSelected: selectedStatusFilter == status
                    ) {
                        selectedStatusFilter = status
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Orders List View
    private var ordersListView: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                let filteredOrders = selectedStatusFilter == nil ? orders : orders.filter { $0.status == selectedStatusFilter }
                
                if filteredOrders.isEmpty {
                    emptyOrdersView
                } else {
                    ForEach(filteredOrders) { order in
                        OrderCard(order: order) {
                            selectedOrder = order
                        }
                    }
                }
            }
            .padding(.horizontal, horizontalSizeClass == .compact ? 16 : 24)
            .padding(.top, 20)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Empty Orders View
    private var emptyOrdersView: some View {
        VStack(spacing: 20) {
            Image(systemName: "bag")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                Text("No orders yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your order history will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 60)
    }
    
    // MARK: - Load Orders
    private func loadOrders() {
        Task {
            await loadOrdersAsync()
        }
    }
    
    private func loadOrdersAsync() async {
        orders = await cartViewModel.fetchOrders()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

// MARK: - Order Card
struct OrderCard: View {
    let order: Order
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Order #\(String(order.id.prefix(8)))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(order.orderDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadge(status: order.status)
                }
                
                // Order Items Preview
                VStack(spacing: 8) {
                    ForEach(order.items.prefix(2)) { item in
                        HStack {
                            Text(item.food.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(item.quantity)x")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if order.items.count > 2 {
                        Text("+ \(order.items.count - 2) more items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Footer
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(String(format: "%.2f", order.totalAmount))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Est. Delivery")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(order.estimatedDeliveryTime, style: .time)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(status.color))
            .cornerRadius(8)
    }
}

// MARK: - Order Detail View
struct OrderDetailView: View {
    let order: Order
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Order Header
                    orderHeaderView
                    
                    // Order Items
                    orderItemsView
                    
                    // Order Details
                    orderDetailsView
                    
                    // Delivery Info
                    deliveryInfoView
                    
                    // Action Buttons
                    actionButtonsView
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Order Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Order Header View
    private var orderHeaderView: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(String(order.id.prefix(8)))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(order.orderDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            // Progress Bar
            ProgressBar(status: order.status)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
    }
    
    // MARK: - Order Items View
    private var orderItemsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Order Items")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                ForEach(order.items) { item in
                    HStack {
                        AsyncImage(url: URL(string: item.food.imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 50, height: 50)
                        .clipped()
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.food.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text(item.food.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(item.quantity)x")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("$\(String(format: "%.2f", item.totalPrice))")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
    }
    
    // MARK: - Order Details View
    private var orderDetailsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Order Details")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                DetailRow(title: "Customer", value: order.customerName)
                DetailRow(title: "Phone", value: order.customerPhone)
                DetailRow(title: "Payment Method", value: order.paymentMethod)
                DetailRow(title: "Total Amount", value: "$\(String(format: "%.2f", order.totalAmount))")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Delivery Info View
    private var deliveryInfoView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Delivery Information")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                DetailRow(title: "Delivery Address", value: order.deliveryAddress)
                DetailRow(title: "Estimated Delivery", value: order.estimatedDeliveryTime, style: .time)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Action Buttons View
    private var actionButtonsView: some View {
        VStack(spacing: 10) {
            if order.status == .pending {
                Button(action: {
                    Task {
                        await cartViewModel.cancelOrder(orderId: order.id)
                        dismiss()
                    }
                }) {
                    Text("Cancel Order")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                }
            }
            
            Button(action: {
                // Share order
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Order")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(15)
            }
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let title: String
    let value: String
    var style: DateFormatter.Style = .none
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if style != .none {
                Text(value, style: style)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            } else {
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let status: OrderStatus
    
    private var progress: Double {
        switch status {
        case .pending: return 0.2
        case .confirmed: return 0.4
        case .preparing: return 0.6
        case .outForDelivery: return 0.8
        case .delivered: return 1.0
        case .cancelled: return 0.0
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.orange)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    OrdersView()
        .environmentObject(CartViewModel())
} 