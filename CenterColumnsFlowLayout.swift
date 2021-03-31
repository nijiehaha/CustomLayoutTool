/// 居中固定列数对齐
class CenterColumnsFlowLayout: UICollectionViewFlowLayout {
    
    //在居中对齐的时候需要知道这行所有cell的宽度总和
    var sumCellWidth : CGFloat = 0.0
    /// 最长的宽度
    var maxWs:[CGFloat] = []
    /// 列数
    var columnNumbers:Int?
    /// 最大内容
    var maxContentFrame = CGRect.zero
    
    //存储布局属性数组，提高性能
    var cache = [UICollectionViewLayoutAttributes]()
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache
    }
    
    /// 固定列数，仅支持一个分组的情况
    func setColumFrame(with layoutAttributes: [UICollectionViewLayoutAttributes]
                     , colums:Int) {
        /// 行数
        var row = -1
        for (index, attribute) in layoutAttributes.enumerated() {
            let column = index % colums
            if column == 0 {
                row += 1
            }
            var nowFrame = attribute.frame
            let h = attribute.frame.size.height
            let w = attribute.frame.size.width
            nowFrame.origin.y = CGFloat(row) * (h + minimumInteritemSpacing) + sectionInset.top
            nowFrame.origin.x = CGFloat(column) * (w + minimumLineSpacing) + sectionInset.bottom
            attribute.frame = nowFrame
        }
        
        /// 居中
        setCenterFrame(with: layoutAttributes)
    }
    
    /// 居中 
    func setCenterFrame(with layoutAttributes: [UICollectionViewLayoutAttributes] ) {
        guard let collection = collectionView else {
            return
        }
        
        let firstItem = cache.first
        let lastItem = cache.last
        let frame = firstItem?.frame.union(lastItem?.frame ?? .zero)
        maxContentFrame = frame ?? collection.frame
        
        var layoutAttributes_t = [UICollectionViewLayoutAttributes]()
        for index in 0..<layoutAttributes.count{
            
            let currentAttr = layoutAttributes[index]
            let nextAttr = index + 1 == layoutAttributes.count ?
                nil : layoutAttributes[index+1]
            
            layoutAttributes_t.append(currentAttr)
            sumCellWidth += currentAttr.frame.size.width
            
            let currentY :CGFloat = currentAttr.frame.maxY
            let nextY:CGFloat = nextAttr == nil ? 0 : nextAttr!.frame.maxY
            
            if currentY != nextY{
                self.setCellFrame(with: layoutAttributes_t)
                layoutAttributes_t.removeAll()
                sumCellWidth = 0.0
            }
        }
    }
    
    /// 调整Cell的Frame
    func setCellFrame(with layoutAttributes : [UICollectionViewLayoutAttributes]){
        guard let collection = collectionView else {
            return
        }
        
        let maxW = sumCellWidth + sectionInset.left * 2 + CGFloat(layoutAttributes.count - 1) * minimumLineSpacing
        maxWs.append(maxW)
                
        guard maxW < collection.frame.size.width, maxContentFrame.height < collection.frame.height else {
            
            if maxW < collection.frame.size.width {
                
                /// 宽度符合居中
                var originX: CGFloat = 0.0
                
                let collectionViewW = collection.frame.size.width
                let newFrameX = (collectionViewW - sumCellWidth - (CGFloat(layoutAttributes.count - 1) * minimumLineSpacing)) / 2
                originX = newFrameX
                for attributes in layoutAttributes {
                    var nowFrame = attributes.frame
                    nowFrame.origin.x = originX
                    attributes.frame = nowFrame
                    originX += nowFrame.size.width + minimumLineSpacing
                }
                
            }
            
            if maxContentFrame.height < collection.frame.height {
                
                /// 高度符合居中
                var originY: CGFloat = 0.0
                
                let collectionViewH = collection.frame.size.height
                let newFrameY = collectionViewH/2 - maxContentFrame.size.height/2
                originY = newFrameY
                for attributes in layoutAttributes {
                    var nowFrame = attributes.frame
                    nowFrame.origin.y += originY
                    attributes.frame = nowFrame
                }
                
            }
            
            return
        }
        
        /// 符合居中
        var originY: CGFloat = 0.0
        var originX: CGFloat = 0.0
        
        let collectionViewW = collection.frame.size.width
        let collectionViewH = collection.frame.size.height
        let newFrameX = (collectionViewW - sumCellWidth - (CGFloat(layoutAttributes.count - 1) * minimumLineSpacing)) / 2
        let newFrameY = collectionViewH/2 - maxContentFrame.size.height/2
        let origin = CGPoint(x: newFrameX, y: newFrameY)
        originX = origin.x
        originY = origin.y
        for attributes in layoutAttributes {
            var nowFrame = attributes.frame
            nowFrame.origin.x = originX
            nowFrame.origin.y += originY
            attributes.frame = nowFrame
            originX += nowFrame.size.width + minimumLineSpacing
        }
    }
    
    override var collectionViewContentSize: CGSize {
        var maxWidth: CGFloat = 0
        for w in maxWs {
            if w > maxWidth {
                maxWidth = w
            }
        }
        return CGSize(width: maxWidth, height: maxContentFrame.size.height)
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collection = collectionView  else {
            return
        }
                
        var layoutInfoArr = [UICollectionViewLayoutAttributes]()
        let numberOfSections = collection.numberOfSections
        
        for section in 0..<numberOfSections {
            let numberOfItems = collection.numberOfItems(inSection: section)
            for item in 0..<numberOfItems {
                let indexPath = IndexPath.init(item: item, section: section)
                if let attributes = layoutAttributesForItem(at: indexPath) {
                    layoutInfoArr.append(attributes)
                }
            }
        }
        
        cache = layoutInfoArr
        
        if let columns = columnNumbers {
            /// 居中且固定列数
            setColumFrame(with: cache, colums: columns)
        } else {
            /// 居中
            setCenterFrame(with: cache)
        }
        
    }
    
}
