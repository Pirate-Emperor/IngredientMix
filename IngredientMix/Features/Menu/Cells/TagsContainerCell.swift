//
//  TagsContainerCell.swift
//  IngredientMix
//

import UIKit

final class TagsContainerCell: UICollectionViewCell {
    static let id = "TagsContainerCell"
    
    var tagsSnapshot = NSDiffableDataSourceSnapshot<Int, String>() {
        didSet {
            selectedStates = []
            tagsSnapshot.itemIdentifiers.forEach { _ in
                selectedStates.append(false)
            }
            selectedStates[activeTagIndex] = true
            dataSource.apply(tagsSnapshot, animatingDifferences: true)
        }
    }
    
    var tagSwitchHandler: ((String) -> Void)?
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    private var selectedStates: [Bool] = []
    private var activeTagIndex = 0
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(TagCell.self, forCellWithReuseIdentifier: TagCell.id)
        collection.showsHorizontalScrollIndicator = false
        collection.backgroundColor = .clear
        collection.delegate = self
        return collection
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(collectionView)
        collectionView.frame = bounds
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCell.id, for: indexPath) as? TagCell 
            else { fatalError("Unable deque TagCell") }
            
            cell.tagButton.setTitle(item, for: .normal)
            cell.tagButton.frame = cell.bounds
            
            if self.selectedStates[indexPath.item] {
                cell.setSelected()
            } else {
                cell.setUnselected()
            }
            
            cell.tagDidTapped = { [weak self] tag in
                self?.setTagLocallySelected(at: indexPath.item)
                self?.tagSwitchHandler?(tag)
            }
            
            return cell
        }
        
        dataSource.apply(tagsSnapshot, animatingDifferences: true)
    }
    
    private func setTagLocallySelected(at index: Int) {
        activeTagIndex = index
        unselectAllTags()
        selectedStates[activeTagIndex] = true
        collectionView.reloadData()
    }
    
    private func unselectAllTags() {
        for index in 0..<selectedStates.count {
            selectedStates[index] = false
        }
    }
    
}

extension TagsContainerCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}

extension TagsContainerCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = tagsSnapshot.itemIdentifiers[indexPath.item]
        let font = UIFont(name: "Raleway", size: 14)!
        let titleWidth = NSString(string: title).width(withFont: font)
        return CGSize(width: titleWidth + 32, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
