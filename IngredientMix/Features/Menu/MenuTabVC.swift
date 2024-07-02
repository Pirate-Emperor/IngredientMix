//
//  TabBarVC.swift
//  IngredientMix
//

import UIKit

final class MenuTabVC: UIViewController {
    
    private var menu = Menu() {
        didSet {
            self.updateMenu()
        }
    }
    
    private var dishColors: [UIColor] = []
    
    private var isMenuReceived = false
    private var isTabBarVisible = true
        
    private var messages: [String] = []
//    private var messages = ["Your order has been accepted.", "Your order is ready and waiting to be delivered.", "Your order is on its way.", "Your order has been successfully delivered. Thank you."]
    
    private let messageCellHeight: CGFloat = 64
    private var messagesTableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var preloaderView = PreloaderView(frame: CGRect(x: 32, y: Int(view.center.y - 100), width: Int(view.frame.width - 64), height: 180))
    
    private lazy var backgroundTapGestureRecognizer: UITapGestureRecognizer = {
        let gr = UITapGestureRecognizer(target: self, action: #selector(hideAllElements))
        gr.cancelsTouchesInView = true
        gr.delegate = self
        return gr
    }()
    
    // MARK: - Header
    
    private var headerBottomPadding: Double = Constants.headerHeight - Constants.headerButtonSize
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.background
        return view
    }()

    private lazy var avatarImageView: UIImageView = {
        let image = UIImage(named: "Guest")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.shared.label.withAlphaComponent(0.5)
        imageView.backgroundColor = ColorManager.shared.headerElementsColor
        imageView.layer.cornerRadius = Constants.headerButtonSize / 2
        imageView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarImageTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var pinImageView: UIImageView = {
        let image = UIImage(named: "Pin")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = ColorManager.shared.label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var deliveryAdressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Set delivery address"
        label.font = UIFont(name: "Raleway", size: 14)
        label.textColor = ColorManager.shared.label
        label.textAlignment = .left
        label.numberOfLines = 1
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deliveryAdressLabelTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var messagesButton: UIButton = {
        let button = UIButton()
        let messagesImage = UIImage(named: "Messages")
        let haveNewMessagesImage = UIImage(named: "HaveNewMessages")
        button.setImage(messagesImage, for: .normal)
        button.setImage(haveNewMessagesImage, for: .selected)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorManager.shared.headerElementsColor
        button.layer.cornerRadius = Constants.headerButtonSize / 2
        button.addTarget(self, action: #selector(messagesButtonTaped), for: .touchUpInside)
        return button
    }()
    
    private lazy var layoutButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Layout")?.resized(to: CGSize(width: 20, height: 20))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image?.withTintColor(ColorManager.shared.label), for: .normal)
        button.backgroundColor = ColorManager.shared.headerElementsColor
        button.layer.cornerRadius = Constants.headerButtonSize / 2
        button.addTarget(self, action: #selector(layoutButtonTaped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Search bar
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.backgroundColor = ColorManager.shared.headerElementsColor
        searchBar.searchTextField.borderStyle = .none
        searchBar.tintColor = ColorManager.shared.orange
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.setPlaceholderFont(.systemFont(ofSize: 14))
        searchBar.updateHeight(to: 44, radius: 22)
        searchBar.setPadding(32, on: .left)
        searchBar.setPadding(44, on: .right)
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var magnifyingGlassImageView: UIImageView = {
        let image = UIImage(named: "Magnifying-glass")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = ColorManager.shared.label
        return imageView
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "Sliders")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.tintColor = ColorManager.shared.label
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var filteredDishes: [Dish] = []
    private var isFilteredByTag = false
    private var isSearching = false
    private var activeTag = "All"
    private var searchString = ""
    private var sortType: SortType = .none
    
    // MARK: - Sort view
    
    enum SortType {
        case none
        case byPriceAscending
        case byPriceDescending
        case byNameAscending
        case byNameDescending
    }
    
    private lazy var sortView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.translucentBackground
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: -40)
        return view
    }()
    
    private lazy var sortViewBlurEffect: UIVisualEffectView = {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect(style: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = blur
        return view
    }()
    
    private lazy var sortButtonsViewStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        return stack
    }()
    
    private lazy var unsortButton: UIButton = {
        let button = UIButton()
        button.setTitle("none", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(ColorManager.shared.orange, for: .selected)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 15, axis: [Constants.fontWeightAxis : 500])
        button.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchDown)
        button.tag = 0
        button.isSelected = true
        return button
    }()
    
    private lazy var sortingByPriceAscendingButton: UIButton = {
        let button = UIButton()
        button.setTitle("  price ↑", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(ColorManager.shared.orange, for: .selected)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 15, axis: [Constants.fontWeightAxis : 500])
        button.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchDown)
        button.tag = 1
        return button
    }()
    
    private lazy var sortingByPriceDescendingButton: UIButton = {
        let button = UIButton()
        button.setTitle("  price ↓", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(ColorManager.shared.orange, for: .selected)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 15, axis: [Constants.fontWeightAxis : 500])
        button.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchDown)
        button.tag = 2
        return button
    }()
    
    private lazy var sortingByNameAscendingButton: UIButton = {
        let button = UIButton()
        button.setTitle("  name ↑", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(ColorManager.shared.orange, for: .selected)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 15, axis: [Constants.fontWeightAxis : 500])
        button.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchDown)
        button.tag = 3
        return button
    }()
    
    private lazy var sortingByNameDescendingButton: UIButton = {
        let button = UIButton()
        button.setTitle("  name ↓", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(ColorManager.shared.orange, for: .selected)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 15, axis: [Constants.fontWeightAxis : 500])
        button.addTarget(self, action: #selector(sortTypeButtonTapped), for: .touchDown)
        button.tag = 4
        return button
    }()
    
    // MARK: - Messages view
    
    private lazy var messagesView: UIView = {
        let view = UIView()
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(messagesViewSwipeUpHandler))
        swipeUpGesture.direction = .up
        view.addGestureRecognizer(swipeUpGesture)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.translucentBackground
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: -40)
        return view
    }()
    
    private lazy var messagesViewBlurEffect: UIVisualEffectView = {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect(style: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.effect = blur
        return view
    }()
    
    private lazy var messagesTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.allowsSelection = false
        table.isScrollEnabled = false
        table.register(MessageCell.self, forCellReuseIdentifier: MessageCell.id)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    // MARK: - Collection view
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(OffersContainerCell.self, forCellWithReuseIdentifier: OffersContainerCell.id)
        view.register(TagsContainerCell.self, forCellWithReuseIdentifier: TagsContainerCell.id)
        view.register(DishCell.self, forCellWithReuseIdentifier: DishCell.id)
        view.delegate = self
        view.backgroundColor = ColorManager.shared.background
        return view
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, AnyHashable>!
    private var snapshot: NSDiffableDataSourceSnapshot<Int, AnyHashable>!
    private var nestedOffersSnapshot = NSDiffableDataSourceSnapshot<Int, Offer>()
    private var nestedTagsSnapshot = NSDiffableDataSourceSnapshot<Int, String>()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureDataSource()
        applyInitialSnapshot()
        getMenuFromCoreData()
        checkMenu()
        
        setKeyboardWillShowObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if !isMenuReceived {
            preloaderView.startLoadingAnimation()
        }
        
        DispatchQueue.main.async {
            self.avatarImageView.image = UserManager.shared.getUserAvatar()
            if let defaultAddress = CoreDataManager.shared.getDefaultAddress() {
                self.deliveryAdressLabel.text = defaultAddress.placeName
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        searchBar.searchTextField.rightViewMode = .always
    }
    
    // MARK: - Collection view methods
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, AnyHashable>(collectionView: collectionView) { collectionView, indexPath, item in
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OffersContainerCell.id, for: indexPath) as? OffersContainerCell
                else { fatalError("Unable deque OffersContainerCell") }
                cell.offersSnapshot = self.nestedOffersSnapshot
                return cell
            case 1:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagsContainerCell.id, for: indexPath) as? TagsContainerCell
                else { fatalError("Unable deque TagsContainerCell") }
                cell.tagSwitchHandler = { [weak self] tag in
                    if self?.activeTag != tag {
                        self?.activeTag = tag
                        self?.filterDishes()
                    }
                }
                cell.tagsSnapshot = self.nestedTagsSnapshot
                return cell
            case 2:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DishCell.id, for: indexPath) as? DishCell
                else { fatalError("Unable deque DishCell") }
                cell.customShapeView.fillColor = self.dishColors[indexPath.item]
                
                let dish = self.filteredDishes[indexPath.item]
                cell.dishData = dish
                cell.isFavorite = dish.isFavorite
                
                cell.isFavoriteDidChange = { [weak self] isFavorite in
                    self?.updateFavoriteStatusLocally(for: dish.id, isFavorite: isFavorite)
                }
                
                return cell
            default:
                return nil
            }
        }
    }
    
    private func applyInitialSnapshot() {
        snapshot = NSDiffableDataSourceSnapshot<Int, AnyHashable>()
        snapshot.appendSections([0, 1, 2])
        
        snapshot.appendItems([menu.offersContainer], toSection: 0)
        snapshot.appendItems([menu.tagsContainer], toSection: 1)
        snapshot.appendItems(menu.dishes, toSection: 2)
    
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applyNestedContainers() {
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: 0))
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: 1))
            
        snapshot.appendItems([menu.offersContainer], toSection: 0)
        snapshot.appendItems([menu.tagsContainer], toSection: 1)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func deleteNestedContainers() {
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: 0))
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: 1))
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applyFilteredSnapshot() {
        snapshot.deleteItems(snapshot.itemIdentifiers(inSection: 2))
        snapshot.appendItems(filteredDishes, toSection: 2)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createOffersSnapshot() -> NSDiffableDataSourceSnapshot<Int, Offer> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Offer>()
        snapshot.appendSections([0])
        snapshot.appendItems(menu.offersContainer.offers, toSection: 0)
        return snapshot
    }
    
    private func createTagsSnapshot() -> NSDiffableDataSourceSnapshot<Int, String> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(menu.tagsContainer.tags, toSection: 0)
        return snapshot
    }
    
    // MARK: - Menu methods
    
    private func updateMenu() {
        if dishColors.count != menu.dishes.count {
            dishColors = ColorManager.shared.getColors(menu.dishes.count)
        }
        
        if !menu.dishes.isEmpty {
            isMenuReceived = true
            preloaderView.isHidden = true
            
            nestedOffersSnapshot = createOffersSnapshot()
            nestedTagsSnapshot = createTagsSnapshot()
            
            applyNestedContainers()
            
            filterDishes()
        }
    }
    
    private func checkMenu() {
        Task {
            do {
                let menuUpdateIsNeeded = try await !MenuManager.shared.isLatestMenuDownloaded()
                if menuUpdateIsNeeded {
                    menu = try await MenuManager.shared.getLatestMenu()
                }
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error in obtaining the actual menu."])
                UserNotification.show(for: error, in: self)
            }
        }
    }
    
    private func getMenuFromCoreData() {
        do {
            if let menu = try CoreDataManager.shared.fetchMenu() {
                self.menu = menu
            }
        } catch {
            ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Error when loading menus from storage."])
            UserNotification.show(for: error, in: self)
        }
    }
    
    private func filterDishes() {
        let dishesToFilter = menu.dishes
        
        if activeTag == "All" {
            isFilteredByTag = false
        } else {
            isFilteredByTag = true
        }
        
        if isSearching {
            let dishesToSort = dishesToFilter.filter { $0.name.lowercased().contains(searchString.lowercased()) }
            filteredDishes = sortDishes(dishesToSort)
            
        } else if isFilteredByTag {
            let dishesToSort  = dishesToFilter.filter { $0.tags.contains(activeTag) }
            filteredDishes = sortDishes(dishesToSort)
            
        } else {
            let dishesToSort = dishesToFilter
            filteredDishes = sortDishes(dishesToSort)
        }
        
        applyFilteredSnapshot()
    }
    
    private func sortDishes(_ dishes: [Dish]) -> [Dish] {
        var dishesToSort = dishes
        
        switch sortType {
        case .none:
            return dishesToSort
        case .byPriceAscending:
            dishesToSort.sort { $0.price < $1.price }
        case .byPriceDescending:
            dishesToSort.sort { $0.price > $1.price }
        case .byNameAscending:
            dishesToSort.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .byNameDescending:
            dishesToSort.sort { $0.name.lowercased() > $1.name.lowercased() }
        }
        
        return dishesToSort
    }
    
    private func updateFavoriteStatusLocally(for id: String, isFavorite: Bool) {
        
        if let index = menu.dishes.firstIndex(where: { $0.id == id }) {
            menu.dishes[index].isFavorite = isFavorite
        }

        if let index = filteredDishes.firstIndex(where: { $0.id == id }) {
            filteredDishes[index].isFavorite = isFavorite
        }
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        view.addSubview(headerView)
        view.addSubview(preloaderView)
        view.addSubview(sortView)
        view.addSubview(messagesView)
        
        headerView.addSubview(avatarImageView)
        headerView.addSubview(pinImageView)
        headerView.addSubview(deliveryAdressLabel)
        headerView.addSubview(messagesButton)
        headerView.addSubview(layoutButton)
        
        messagesView.addSubview(messagesViewBlurEffect)
        messagesView.addSubview(messagesTableView)
        
        searchBar.addSubview(magnifyingGlassImageView)
        searchBar.addSubview(sortButton)
        
        sortView.addSubview(sortViewBlurEffect)
        sortView.addSubview(sortButtonsViewStack)
        
        sortButtonsViewStack.addArrangedSubview(unsortButton)
        sortButtonsViewStack.addArrangedSubview(createSeparatorView())
        sortButtonsViewStack.addArrangedSubview(sortingByPriceAscendingButton)
        sortButtonsViewStack.addArrangedSubview(createSeparatorView())
        sortButtonsViewStack.addArrangedSubview(sortingByPriceDescendingButton)
        sortButtonsViewStack.addArrangedSubview(createSeparatorView())
        sortButtonsViewStack.addArrangedSubview(sortingByNameAscendingButton)
        sortButtonsViewStack.addArrangedSubview(createSeparatorView())
        sortButtonsViewStack.addArrangedSubview(sortingByNameDescendingButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Constants.headerHeight),
            
            avatarImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            avatarImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            
            pinImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -headerBottomPadding / 2),
            pinImageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            pinImageView.heightAnchor.constraint(equalToConstant: 20),
            pinImageView.widthAnchor.constraint(equalToConstant: 20),
            layoutButton.topAnchor.constraint(equalTo: headerView.topAnchor),
            layoutButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            layoutButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -headerBottomPadding),
            layoutButton.widthAnchor.constraint(equalTo: layoutButton.heightAnchor),
            messagesButton.topAnchor.constraint(equalTo: headerView.topAnchor),
            messagesButton.trailingAnchor.constraint(equalTo: layoutButton.leadingAnchor, constant: -10),
            messagesButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -headerBottomPadding),
            messagesButton.widthAnchor.constraint(equalTo: messagesButton.heightAnchor),
            deliveryAdressLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -headerBottomPadding / 2),
            deliveryAdressLabel.leadingAnchor.constraint(equalTo: pinImageView.trailingAnchor, constant: 6),
            deliveryAdressLabel.trailingAnchor.constraint(equalTo: messagesButton.leadingAnchor, constant: -10),
            deliveryAdressLabel.heightAnchor.constraint(equalToConstant: 30),
            
            messagesView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
            messagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            messagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            messagesViewBlurEffect.topAnchor.constraint(equalTo: messagesView.topAnchor),
            messagesViewBlurEffect.leadingAnchor.constraint(equalTo: messagesView.leadingAnchor),
            messagesViewBlurEffect.trailingAnchor.constraint(equalTo: messagesView.trailingAnchor),
            messagesViewBlurEffect.bottomAnchor.constraint(equalTo: messagesView.bottomAnchor),
            messagesTableView.topAnchor.constraint(equalTo: messagesView.topAnchor),
            messagesTableView.leadingAnchor.constraint(equalTo: messagesView.leadingAnchor),
            messagesTableView.trailingAnchor.constraint(equalTo: messagesView.trailingAnchor),
            messagesTableView.bottomAnchor.constraint(equalTo: messagesView.bottomAnchor),
            
            searchBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 54),
            
            magnifyingGlassImageView.widthAnchor.constraint(equalToConstant: 18),
            magnifyingGlassImageView.heightAnchor.constraint(equalToConstant: 18),
            magnifyingGlassImageView.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            magnifyingGlassImageView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 24),
            
            sortButton.widthAnchor.constraint(equalToConstant: 40),
            sortButton.heightAnchor.constraint(equalToConstant: 40),
            sortButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            sortButton.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -14),
            
            sortView.topAnchor.constraint(equalTo: sortButton.bottomAnchor, constant: 8),
            sortView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            sortView.widthAnchor.constraint(equalToConstant: 120),
            sortView.heightAnchor.constraint(equalToConstant: 220),
            sortViewBlurEffect.topAnchor.constraint(equalTo: sortView.topAnchor),
            sortViewBlurEffect.leadingAnchor.constraint(equalTo: sortView.leadingAnchor),
            sortViewBlurEffect.trailingAnchor.constraint(equalTo: sortView.trailingAnchor),
            sortViewBlurEffect.bottomAnchor.constraint(equalTo: sortView.bottomAnchor),
            sortButtonsViewStack.topAnchor.constraint(equalTo: sortView.topAnchor),
            sortButtonsViewStack.leadingAnchor.constraint(equalTo: sortView.leadingAnchor),
            sortButtonsViewStack.trailingAnchor.constraint(equalTo: sortView.trailingAnchor),
            sortButtonsViewStack.bottomAnchor.constraint(equalTo: sortView.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        messagesTableViewHeightConstraint = messagesTableView.heightAnchor.constraint(equalToConstant: 0)
        messagesTableViewHeightConstraint?.isActive = true
    }
    
    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = ColorManager.shared.label.withAlphaComponent(0.4)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    private func hideMessagesView() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.messagesView.transform = CGAffineTransform(translationX: 0, y: -40)
            self.messagesView.alpha = 0
        }
    }
    
    private func showMessagesView() {
        view.addGestureRecognizer(backgroundTapGestureRecognizer)
        updateMessagesTableViewHeight()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            self.messagesView.transform = .identity
            self.messagesView.alpha = 1
        }
    }
    
    private func hideSortView() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.sortView.transform = CGAffineTransform(translationX: 0, y: -40)
            self.sortView.alpha = 0
        }
    }
    
    private func showSortView() {
        view.addGestureRecognizer(backgroundTapGestureRecognizer)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            self.sortView.transform = .identity
            self.sortView.alpha = 1
        }
    }
    
    private func hideTabBar() {
        isTabBarVisible = false
        let parent = self.parent as! TabBarVC
        parent.hideTabBar()
    }
    
    private func showTabBar() {
        isTabBarVisible = true
        let parent = self.parent as! TabBarVC
        parent.showTabBar()
    }
    
    private func hideSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.searchBar.transform = CGAffineTransform(translationX: 0, y: -40)
            self.searchBar.alpha = 0.0
        }
    }
    
    private func showSearchBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5) {
            self.searchBar.transform = .identity
            self.searchBar.alpha = 1
        }
    }
    
    private func updateMessagesTableViewHeight() {
        let numberOfRows = messagesTableView.numberOfRows(inSection: 0)
        messagesTableViewHeightConstraint?.constant = CGFloat(numberOfRows) * messageCellHeight
    }
    
    private func setKeyboardWillShowObserver() {
        NotificationCenter.default.addObserver(self,selector: #selector(handleKeyboardWillShow),name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - scrollViewDidScroll
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === collectionView {
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            if translation.y == 0 { return }
            if translation.y > 0 {
                if !isTabBarVisible { showTabBar() }
                if !isSearching { showSearchBar() }
            } else {
                if isTabBarVisible { hideTabBar() }
                if !isSearching { hideSearchBar() }
                dismissKeyboard()
                hideSortView()
            }
        }
        
        if scrollView.contentOffset.y <= 0 {
            if !isTabBarVisible { showTabBar() }
            if !isSearching { showSearchBar() }
        }
    }
    
    // MARK: - Objc methods
    
    @objc
    private func avatarImageTapped() {
        
    }
    
    @objc
    private func deliveryAdressLabelTapped() {
        
    }
    
    @objc
    private func messagesButtonTaped() {
        showMessagesView()
    }
    
    @objc
    private func layoutButtonTaped() {
        // for testing
        let vc = InitialVC()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    @objc
    private func sortButtonTapped() {
        showSortView()
    }
    
    @objc
    private func sortTypeButtonTapped(_ sender: UIButton) {
        guard sender.isSelected == false else {
            hideSortView()
            return
        }
        
        if sender.tag == 0 {
            sortButton.tintColor = ColorManager.shared.label
        } else {
            sortButton.tintColor = ColorManager.shared.orange
        }
        
        [unsortButton, sortingByNameAscendingButton, sortingByNameDescendingButton, sortingByPriceAscendingButton, sortingByPriceDescendingButton].forEach { button in
            button.isSelected = false
        }
        sender.isSelected = true
        
        switch sender.tag {
        case 0: // none
            sortType = .none
        case 1: // price ↑
            sortType = .byPriceAscending
        case 2: // price ↓
            sortType = .byPriceDescending
        case 3: // name ↑
            sortType = .byNameAscending
        case 4: // name ↓
            sortType = .byNameDescending
        default:
            break
        }
        
        hideSortView()

        filterDishes()
    }
    
    @objc
    private func handleKeyboardWillShow() {
        view.addGestureRecognizer(backgroundTapGestureRecognizer)
    }
    
    @objc
    private func messagesViewSwipeUpHandler() {
        hideMessagesView()
    }
    
    @objc
    private func hideAllElements() {
        view.removeGestureRecognizer(backgroundTapGestureRecognizer)
        dismissKeyboard()
        hideSortView()
        hideMessagesView()
    }
    
}

// MARK: - UICollectionViewDelegate

extension MenuTabVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDish = filteredDishes[indexPath.item]
        let cell = collectionView.cellForItem(at: indexPath) as? DishCell
        let color = cell?.customShapeView.fillColor ?? ColorManager.shared.green
        
        let dishVC = DishVC(dish: selectedDish, color: color)
        
        dishVC.isFavoriteDidChange = { [weak self] isFavorite in
            self?.updateFavoriteStatusLocally(for: selectedDish.id, isFavorite: isFavorite)
        }
        
        dishVC.modalTransitionStyle = .coverVertical
        dishVC.modalPresentationStyle = .fullScreen
        
        present(dishVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let offerContainerCell = cell as? OffersContainerCell {
            offerContainerCell.reloadCollectionView()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MenuTabVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: view.frame.width, height: 152)
        case 1:
            return CGSize(width: view.frame.width, height: 38)
        case 2:
            let parentWidth = collectionView.bounds.width
            let itemWidth = (parentWidth / 2 - 24)
            let itemHeight = itemWidth * 1.264
            return CGSize(width: itemWidth, height: itemHeight)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsets(top: 54, left: 0, bottom: 0, right: 0)
        case 1:
            return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        case 2:
            return UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        default:
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
}

// MARK: - UITableViewDelegate

extension MenuTabVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages.count == 0 {
            return 1
        }
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.id, for: indexPath) as! MessageCell
        
        if messages.count == 0 {
            cell.setAsNoMessagesCell()
        } else {
            cell.message = messages[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        messageCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.subviews.forEach { subview in
            if subview is SeparatorView {
                subview.removeFromSuperview()
            }
        }

        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            let separatorHeight: CGFloat = 1.0
            let separator = SeparatorView(frame: CGRect(x: 0, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width, height: separatorHeight))
            cell.contentView.addSubview(separator)
        }
    }
}

// MARK: - UISearchBarDelegate

extension MenuTabVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText
        
        if searchText.isEmpty {
            isSearching = false
            applyNestedContainers()
            filterDishes()
            return
        }
        
        isSearching = true
        deleteNestedContainers()
        filterDishes()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension MenuTabVC: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if messagesView.frame.contains(touch.location(in: view)) {
            return false
        } else if sortView.frame.contains(touch.location(in: view)) {
            return false
        }
        
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
