import UIKit

class WaterfallFlowLayout: UICollectionViewFlowLayout {
            
    /// 列数
    let numberOfColumns = 2
    
    //存储布局属性数组，提高性能
    var cache = [UICollectionViewLayoutAttributes]()
    
    override func prepare() {
                
        super.prepare()
        
        cache.removeAll()
                        
        minimumInteritemSpacing = 16
        minimumLineSpacing =  16
        sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
    }
        
    private var columnHeights = [Int:CGFloat]()
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attrs = super.layoutAttributesForElements(in: rect), attrs.count > 0 else {
            return super.layoutAttributesForElements(in: rect)
        }

        columnHeights = [Int:CGFloat]()

        columnHeights = (0..<numberOfColumns).reduce([Int:CGFloat]()) { (res, num) -> [Int:CGFloat] in
            var value = res
            value[num] = 0
            return value
        }

        for attr in attrs {

            /// item 的宽高
            let itemWidth = attr.frame.size.width
            let itemHeight  = attr.frame.size.height

            var minIndex = 0
            for column in columnHeights {
                if column.value < columnHeights[minIndex] ?? 0 {
                    minIndex = column.key
                }
            }

           /// item 的 x, y 值
           let itemX  = 16 + (itemWidth + 16) * CGFloat(minIndex)
           let itemY  = (columnHeights[minIndex] ?? 0) + 16

           attr.frame  = CGRect(x: itemX, y: itemY, width: itemWidth, height: itemHeight)

           columnHeights[minIndex] = attr.frame.maxY

        }

        return attrs
                
    }

    override var collectionViewContentSize: CGSize {

        var maxHeight: CGFloat = 0
        for height in columnHeights.values {
            if height > maxHeight {
                maxHeight = height
            }
        }
        return CGSize(width: collectionView?.frame.width ?? 0, height: maxHeight + sectionInset.bottom)

    }

    
}
