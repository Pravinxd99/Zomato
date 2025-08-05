import UIKit
import SwiftUI

class FavoritesViewController: UIViewController {
    
    // MARK: - Properties
    private var favorites: [Food] = []
    private var filteredFavorites: [Food] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.register(FavoriteFoodCell.self, forCellWithReuseIdentifier: "FavoriteFoodCell")
        collectionView.register(EmptyStateView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "EmptyStateView")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.tintColor = .systemOrange
        return refreshControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSearchController()
        loadFavorites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add collection view
        view.addSubview(collectionView)
        collectionView.refreshControl = refreshControl
        
        // Setup constraints
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add right bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(showFilterOptions)
        )
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search favorites..."
        searchController.searchBar.tintColor = .systemOrange
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Data Loading
    private func loadFavorites() {
        // Load favorites from UserDefaults or Core Data
        favorites = FavoritesManager.shared.getFavorites()
        filteredFavorites = favorites
        collectionView.reloadData()
    }
    
    @objc private func refreshData() {
        loadFavorites()
        refreshControl.endRefreshing()
    }
    
    @objc private func showFilterOptions() {
        let alertController = UIAlertController(title: "Filter Favorites", message: nil, preferredStyle: .actionSheet)
        
        let allAction = UIAlertAction(title: "All Favorites", style: .default) { _ in
            self.filterFavorites(by: nil)
        }
        
        let categories = FoodCategory.allCases
        for category in categories {
            let action = UIAlertAction(title: category.rawValue, style: .default) { _ in
                self.filterFavorites(by: category)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func filterFavorites(by category: FoodCategory?) {
        if let category = category {
            filteredFavorites = favorites.filter { $0.category == category }
        } else {
            filteredFavorites = favorites
        }
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension FavoritesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredFavorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteFoodCell", for: indexPath) as! FavoriteFoodCell
        let food = filteredFavorites[indexPath.item]
        cell.configure(with: food)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader && filteredFavorites.isEmpty {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "EmptyStateView", for: indexPath) as! EmptyStateView
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate
extension FavoritesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let food = filteredFavorites[indexPath.item]
        showFoodDetail(for: food)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FavoritesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let availableWidth = collectionView.bounds.width - (padding * 3)
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 280)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if filteredFavorites.isEmpty {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
        return CGSize.zero
    }
}

// MARK: - UISearchResultsUpdating
extension FavoritesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredFavorites = favorites
            collectionView.reloadData()
            return
        }
        
        filteredFavorites = favorites.filter { food in
            food.name.localizedCaseInsensitiveContains(searchText) ||
            food.description.localizedCaseInsensitiveContains(searchText) ||
            food.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
        collectionView.reloadData()
    }
}

// MARK: - FavoriteFoodCellDelegate
extension FavoritesViewController: FavoriteFoodCellDelegate {
    func didTapRemoveFavorite(_ cell: FavoriteFoodCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let food = filteredFavorites[indexPath.item]
        
        let alertController = UIAlertController(
            title: "Remove from Favorites",
            message: "Are you sure you want to remove '\(food.name)' from your favorites?",
            preferredStyle: .alert
        )
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            FavoritesManager.shared.removeFromFavorites(food)
            self.loadFavorites()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func didTapAddToCart(_ cell: FavoriteFoodCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let food = filteredFavorites[indexPath.item]
        
        // Show quantity picker
        let alertController = UIAlertController(title: "Add to Cart", message: "Select quantity for \(food.name)", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Quantity"
            textField.keyboardType = .numberPad
            textField.text = "1"
        }
        
        let addAction = UIAlertAction(title: "Add to Cart", style: .default) { _ in
            guard let textField = alertController.textFields?.first,
                  let quantityText = textField.text,
                  let quantity = Int(quantityText), quantity > 0 else {
                return
            }
            
            // Add to cart (this would integrate with your SwiftUI cart)
            self.addToCart(food: food, quantity: quantity)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func addToCart(food: Food, quantity: Int) {
        // This would integrate with your SwiftUI cart
        // For now, we'll show a success message
        let alertController = UIAlertController(
            title: "Added to Cart",
            message: "\(quantity)x \(food.name) has been added to your cart",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    private func showFoodDetail(for food: Food) {
        // Create SwiftUI view and present it
        let foodDetailView = FoodDetailView(food: food)
        let hostingController = UIHostingController(rootView: foodDetailView)
        hostingController.title = food.name
        navigationController?.pushViewController(hostingController, animated: true)
    }
}

// MARK: - FavoriteFoodCell
class FavoriteFoodCell: UICollectionViewCell {
    
    // MARK: - Properties
    weak var delegate: FavoriteFoodCellDelegate?
    private var food: Food?
    
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .systemOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addToCartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add to Cart", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(removeButton)
        contentView.addSubview(addToCartButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.6),
            
            removeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            removeButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            removeButton.widthAnchor.constraint(equalToConstant: 24),
            removeButton.heightAnchor.constraint(equalToConstant: 24),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            categoryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            priceLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            ratingLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            addToCartButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            addToCartButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            addToCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addToCartButton.heightAnchor.constraint(equalToConstant: 36),
            addToCartButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupActions() {
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    func configure(with food: Food) {
        self.food = food
        
        nameLabel.text = food.name
        categoryLabel.text = food.category.rawValue
        priceLabel.text = String(format: "$%.2f", food.price)
        ratingLabel.text = String(format: "★ %.1f", food.rating)
        
        // Load image
        if let url = URL(string: food.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        self?.imageView.image = image
                    } else {
                        self?.imageView.image = UIImage(systemName: "photo")
                        self?.imageView.tintColor = .systemGray
                    }
                }
            }.resume()
        }
    }
    
    // MARK: - Actions
    @objc private func removeButtonTapped() {
        delegate?.didTapRemoveFavorite(self)
    }
    
    @objc private func addToCartButtonTapped() {
        delegate?.didTapAddToCart(self)
    }
}

// MARK: - FavoriteFoodCellDelegate
protocol FavoriteFoodCellDelegate: AnyObject {
    func didTapRemoveFavorite(_ cell: FavoriteFoodCell)
    func didTapAddToCart(_ cell: FavoriteFoodCell)
}

// MARK: - EmptyStateView
class EmptyStateView: UICollectionReusableView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "No Favorites Yet"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start adding your favorite foods to see them here"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
} 