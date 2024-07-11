//
//  TabBarVC.swift
//  IngredientMix
//

import UIKit

final class FavoriteTabVC: UIViewController {
    
    private lazy var favoriteDishes: [Dish] = [] {
        didSet {
            if favoriteDishes.isEmpty {
                emptyFavoriteView.isHidden = false
                tableView.isHidden = true
            } else {
                emptyFavoriteView.isHidden = true
                tableView.isHidden = false
            }
        }
    }

    private lazy var favoriteTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.label
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        label.text = "Favorite"
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = ColorManager.shared.background
        table.separatorStyle = .none
        table.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.id)
        table.dataSource = self
        table.delegate = self
        table.isHidden = true
        return table
    }()
    
    // MARK: - Empty cart view props.
    
    private lazy var emptyFavoriteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var favoriteIsEmptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = ColorManager.shared.label
        label.text = "You haven't chosen a favorite yet"
        label.font = UIFont(name: "Raleway", size: 22)
        label.numberOfLines = 1
        label.layer.shadowOffset = CGSize(width: 3, height: 3)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        return label
    }()
    
    private lazy var emptyFavoriteImageView: UIImageView = {
        let image = UIImage(named: "EmptyFavorite")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        do {
            let favorite = try CoreDataManager.shared.fetchFavorites()
            if favoriteDishes != favorite {
                favoriteDishes = favorite
                tableView.reloadData()
            }
        } catch {
            let notification = UserNotification(message: "Failed to load favorite dishes.", type: .error)
            notification.show(in: self)
        }
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        
        view.addSubview(favoriteTitle)
        view.addSubview(tableView)
        view.addSubview(emptyFavoriteView)
        
        emptyFavoriteView.addSubview(favoriteIsEmptyLabel)
        emptyFavoriteView.addSubview(emptyFavoriteImageView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            favoriteTitle.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 3),
            favoriteTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: favoriteTitle.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyFavoriteView.topAnchor.constraint(equalTo: favoriteTitle.bottomAnchor, constant: 43),
            emptyFavoriteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyFavoriteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyFavoriteView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            favoriteIsEmptyLabel.centerXAnchor.constraint(equalTo: emptyFavoriteView.centerXAnchor),
            favoriteIsEmptyLabel.topAnchor.constraint(equalTo: emptyFavoriteView.topAnchor, constant: 100),
            emptyFavoriteImageView.topAnchor.constraint(equalTo: favoriteIsEmptyLabel.bottomAnchor, constant: 47),
            emptyFavoriteImageView.centerXAnchor.constraint(equalTo: emptyFavoriteView.centerXAnchor),
            emptyFavoriteImageView.heightAnchor.constraint(equalToConstant: 270),
            emptyFavoriteImageView.widthAnchor.constraint(equalToConstant: 255)
        ])
    }
    
    private func deleteFromFavorite(at indexPath: IndexPath) {
        do {
            let itemToDelete = favoriteDishes[indexPath.row]
            try CoreDataManager.shared.deleteFromFavorite(by: itemToDelete.id)
            favoriteDishes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            let notification = UserNotification(message: "Failed to remove dish from favorites. Please try again.", type: .error)
            notification.show(in: self)
        }
    }
}

// MARK: - TableView delegate methods

extension FavoriteTabVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteDishes.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == favoriteDishes.count {
            let cell = UITableViewCell()
            cell.backgroundColor = ColorManager.shared.background
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.id, for: indexPath) as! FavoriteCell
        cell.favoriteDish = favoriteDishes[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != favoriteDishes.count {
            var relatedProducts: [UIImage] = []
            
            for item in favoriteDishes {
                if let data = item.imageData, let image = UIImage(data: data) {
                    if relatedProducts.count != 3 {
                        relatedProducts.append(image)
                    } else {
                        break
                    }
                }
            }
            
            let dishPage = DishVC(dish: favoriteDishes[indexPath.row])
            
            dishPage.modalTransitionStyle = .coverVertical
            dishPage.modalPresentationStyle = .fullScreen
            
            present(dishPage, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completionHandler) in
            self?.deleteFromFavorite(at: indexPath)
            completionHandler(true)
        }
        
        if let trashImage = UIImage(systemName: "trash") {
            let size = CGSize(width: 26, height: 30)
            let renderer = UIGraphicsImageRenderer(size: size)
            let tintedImage = renderer.image { context in
                trashImage.withTintColor(ColorManager.shared.warningRed).draw(in: CGRect(origin: .zero, size: size))
            }
            deleteAction.image = tintedImage
        }
        
        deleteAction.backgroundColor = ColorManager.shared.background

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.subviews.forEach { subview in
            if subview is SeparatorView {
                subview.removeFromSuperview()
            }
        }

        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row < totalRows - 2 {
            let separatorHeight: CGFloat = 1.0
            let separator = SeparatorView(frame: CGRect(x: 16, y: cell.contentView.frame.size.height - separatorHeight, width: cell.contentView.frame.size.width - 32, height: separatorHeight))
            cell.contentView.addSubview(separator)
        }
    }
}
