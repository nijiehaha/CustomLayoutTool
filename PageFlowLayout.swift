import UIKit

class PageFlowLayout: UICollectionViewFlowLayout {
    
    var currentIndex = 0
    
    override init() {
        super.init()
    }
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = .fast
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        var proposedContentOffset = proposedContentOffset
        let pageWidth = itemSize.width * 2 + minimumLineSpacing + sectionInset.left
        let rawPageValue = collectionView.contentOffset.x/pageWidth
        let currentPage = velocity.x > 0.0 ? floor(rawPageValue): ceil(rawPageValue)
        let nextPage = velocity.x > 0.0 ? ceil(rawPageValue): floor(rawPageValue)
        let pannedLessThanAPage = abs(1 + currentPage - rawPageValue) > 0.5
        let flicked = abs(velocity.x) > 0.3
        if pannedLessThanAPage && flicked {
            proposedContentOffset.x = nextPage * pageWidth
        } else {
            proposedContentOffset.x = round(rawPageValue) * pageWidth
        }
        currentIndex = nextPage
        return proposedContentOffset
    }
    
}
