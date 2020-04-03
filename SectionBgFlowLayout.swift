import UIKit

//增加自己的协议方法，使其可以像cell那样根据数据源来设置section背景色
protocol SectionBgCollectionViewDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        backgroundColorForSectionAt section: Int) -> UIColor
}

// 定义一个UICollectionViewLayoutAttributes子类作为section背景的布局属性，
//（在这里定义一个backgroundColor属性表示Section背景色）
class SectionBgCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
     
    // 背景色
    var backgroundColor = UIColor.red
     
    // 所定义属性的类型需要遵从 NSCopying 协议
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! SectionBgCollectionViewLayoutAttributes
        copy.backgroundColor = self.backgroundColor
        return copy
    }

    // 所定义属性的类型还要实现相等判断方法（isEqual）
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? SectionBgCollectionViewLayoutAttributes else {
            return false
        }

        if !self.backgroundColor.isEqual(rhs.backgroundColor) {
            return false
        }
        return super.isEqual(object)
    }
    
}

/// 自定义 装饰视图
class SectionBgView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1
        layer.shadowRadius = 30
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 重写 apply
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        
        super.apply(layoutAttributes)
        
        guard let attr = layoutAttributes as? SectionBgCollectionViewLayoutAttributes else
        {
            return
        }
         
        self.backgroundColor = attr.backgroundColor
        
    }
    
}

/// 自定义 FlowLayout
class SectionBgFlowLayout: UICollectionViewFlowLayout {

    let decorationViewKind = "SectionBgView"
    
    var decorationViewAttrs: [UICollectionViewLayoutAttributes] = []
    
    override init() {
        
        super.init()
        
        register(SectionBgView.self, forDecorationViewOfKind: decorationViewKind)
        
    }
    
    /// 对一些布局的准备操作放在这里
    override func prepare() {
        super.prepare()
         
        /// 如果collectionView当前没有分区，或者未实现相关的代理则直接退出
        guard let numberOfSections = self.collectionView?.numberOfSections,
            let delegate = self.collectionView?.delegate
                as? SectionBgCollectionViewDelegate
            else {
                return
        }
         
        /// 先删除原来的section背景的布局属性
        self.decorationViewAttrs.removeAll()
         
        /// 分别计算每个section背景的布局属性
        for section in 0..<numberOfSections {
            /// 获取该section下第一个，以及最后一个item的布局属性
            guard let numberOfItems = self.collectionView?.numberOfItems(inSection:
                section),
                numberOfItems > 0,
                let firstItem = self.layoutAttributesForItem(at:
                    IndexPath(item: 0, section: section)),
                let lastItem = self.layoutAttributesForItem(at:
                    IndexPath(item: numberOfItems - 1, section: section))
                else {
                    continue
            }
             
            /// 计算section的frame
            let sectionFrame = firstItem.frame.union(lastItem.frame)
            
            /// 更具上面的结果计算section背景的布局属性
            let attr = SectionBgCollectionViewLayoutAttributes(
                forDecorationViewOfKind: decorationViewKind,
                with: IndexPath(item: 0, section: section))
            attr.frame = sectionFrame
            attr.zIndex = -1
            /// 通过代理方法获取该section背景使用的颜色
            attr.backgroundColor = delegate.collectionView(self.collectionView!,
                           layout: self, backgroundColorForSectionAt: section)
             
            /// 将该section背景的布局属性保存起来
            self.decorationViewAttrs.append(attr)
        }
    }
     
    /// 返回rect范围下所有元素的布局属性（这里我们将自定义的section背景视图的布局属性也一起返回）
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
        var attrs = super.layoutAttributesForElements(in: rect)
        attrs?.append(contentsOf: self.decorationViewAttrs.filter {
            return rect.intersects($0.frame)
        })
        return attrs
    }
     
    /// 返回对应于indexPath的位置的Decoration视图的布局属性
    override func layoutAttributesForDecorationView(ofKind elementKind: String,
                at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        /// 如果是我们自定义的Decoration视图（section背景），则返回它的布局属性
        if elementKind == decorationViewKind {
            return self.decorationViewAttrs[indexPath.section]
        }
        return super.layoutAttributesForDecorationView(ofKind: elementKind,
                                                       at: indexPath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
