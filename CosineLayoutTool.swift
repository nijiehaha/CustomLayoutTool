//
//  CosineLayoutTool.swift
//  ProfessionalIDPhotoSwift
//
//  Created by lufei on 2020/3/26.
//  Copyright © 2020 leqi. All rights reserved.
//

import UIKit

/// 余弦函数布局工具类
class CosineLayoutTool: UICollectionViewFlowLayout {

    /// 居中卡片高度与collection的高度比
    let cardHeightScale:CGFloat = 1.0
    
    /// 宽度
    var itemWidth:CGFloat {
        return itemHeight
    }
    
    /// 高度
    var itemHeight:CGFloat {
        return collectionView?.bounds.size.height ?? 0
    }
    
    /// 是否实时刷新布局
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        
        super.prepare()
        
        let insetX = ((collectionView?.bounds.size.width ?? 0) - itemWidth)/2.0
        
        scrollDirection = .horizontal
        sectionInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)
        itemSize = CGSize(width: itemWidth, height: itemHeight)
        minimumLineSpacing = 5
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributesArr = super.layoutAttributesForElements(in: rect) else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        /// 中心位置
        let centerX = (collectionView?.contentOffset.x ?? 0) + (collectionView?.bounds.size.width ?? 0)/2.0
        /// 最大移动距离，计算范围是移动出屏幕前的距离
        let maxApart = ((collectionView?.bounds.size.width ?? 0) + itemWidth)/2.0
        
        for attributes in attributesArr {
            /// 获取cell中心和屏幕中心的距离
            let apart = abs(attributes.center.x - centerX)
            /// 移动进度 -1~0~1
            let progress = apart/maxApart
            /// 在屏幕外的cell不处理
            if abs(progress) > 1 { continue }
            /// 根据余弦函数，弧度在 -π/4 到 π/4,即 scale在 √2/2~1~√2/2 间变化
            let scale = abs(cos(Double(progress) * Double.pi/4))
            /// 缩放大小
            attributes.transform = CGAffineTransform(scaleX: CGFloat(scale), y: CGFloat(scale))
        }
        
        return attributesArr
        
    }
    
}
