//
//  OffersContainerCell.swift
//  IngredientMix
//

import UIKit

final class OffersContainerCell: UICollectionViewCell {
    static let id = "OffersContainerCell"
    
    private lazy var slideWidth: CGFloat = frame.width * 0.65
    private lazy var cellsPrimaryColors: [UIColor] = []
    private let sliderSpacing = 16.0
    private var indexOfCellBeforeDragging = 0
    private var dataSource: UICollectionViewDiffableDataSource<Int, Offer>!
    
    var offersSnapshot = NSDiffableDataSourceSnapshot<Int, Offer>() {
        didSet{
            cellsPrimaryColors = ColorManager.shared.getColors(offersSnapshot.numberOfItems)
            dataSource.apply(offersSnapshot, animatingDifferences: false)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(OfferCell.self, forCellWithReuseIdentifier: OfferCell.id)
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
        dataSource = UICollectionViewDiffableDataSource<Int, Offer>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.id, for: indexPath) as? OfferCell 
            else { fatalError("Unable deque OfferCell") }
            cell.primaryColor = self.cellsPrimaryColors[indexPath.item]
            cell.offerData = self.offersSnapshot.itemIdentifiers[indexPath.item]
            return cell
        }
        dataSource.apply(offersSnapshot, animatingDifferences: false)
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(x: collectionView.contentOffset.x + collectionView.bounds.size.width / 2, y: collectionView.bounds.size.height / 2)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            indexOfCellBeforeDragging = indexPath.item
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset
        
        let pageWidth = slideWidth + sliderSpacing
        let collectionViewItemCount = offersSnapshot.itemIdentifiers.count
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        let indexOfMajorCell = Int(round(proportionalOffset))
        let swipeVelocityThreshold: CGFloat = 0.0
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)

        if didUseSwipeToSkipCell {
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let indexPath = IndexPath(row: snapToIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        } else {
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

extension OffersContainerCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension OffersContainerCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: slideWidth, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sliderSpacing
    }
}
