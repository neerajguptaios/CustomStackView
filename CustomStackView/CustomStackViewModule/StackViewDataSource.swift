//
//  StackViewDataSource.swift
//  TestSwift
//
//  Created by Neeraj Gupta on 27/02/20.
//  Copyright © 2020 Neeraj Gupta. All rights reserved.
//

import UIKit

public struct StackIndex : Equatable{
    public var row : Int
    public var section : Int
    public static func ==(lhs: StackIndex, rhs: StackIndex) -> Bool {
        return lhs.row == rhs.row && lhs.section == rhs.section
    }
    public var indexPath : IndexPath {
        return IndexPath(row: row, section: section)
    }
    public init(row: Int, section: Int) {
        self.row = row
        self.section = section
    }
}
public struct StackInset {
    public var leading : CGFloat
    public var trailing : CGFloat
    public var top : CGFloat
    public var bottom : CGFloat
    
    public init(leading: CGFloat, trailing: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.leading = leading
        self.trailing = trailing
        self.top = top
        self.bottom = bottom
    }
    
    static public var zero = StackInset(leading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
}

@objc public protocol CustomStackViewBaseModel: AnyObject {
    // base model
}

@objc public protocol AbstractCustomStackViewProtocol {
    @objc func reloadCustomStackSubView(with model: CustomStackViewBaseModel)
}

extension UIView : AbstractCustomStackViewProtocol {
    open func reloadCustomStackSubView(with model: CustomStackViewBaseModel){
        // should be overridden in the child class
        print("checkkdshf sfkjshdfk shdkg h")
    }
}

public protocol StackViewDataSource: AnyObject {

    
    
    // @required methods
    
    // number of rows in the given section
    func numberOfRowsInSection(in section : Int, stackView : UIView) -> Int?
    
    // view for that particular row in section
    func viewForRowAtStackIndex( stackIndex : StackIndex, stackView : UIView) -> UIView
    
    
    
    
    
    
    
    
    // @optional methods
    
    // total number of sections in stackview, default is 1
    func numberOfSections(in stackView : UIView) -> Int?
    
    // for any complete section, if you need to set any background view then define this method and return that view. Default is clear view
    func backgroundViewForSectionAtSection(section : Int, stackView : UIView) -> UIView
    
    // axis for stackview, it can be vertical or horizontal. Default is vertical
    func axisForStackView(stackView : UIView) -> NSLayoutConstraint.Axis
    
    // axis for stackview, it can be vertical or horizontal. Default is vertical
    func alignmentForSection(section : Int, stackView : UIView) -> UIStackView.Alignment
    // axis for stackview, it can be vertical or horizontal. Default is vertical
    func distributionForSection(section : Int, stackView : UIView) -> UIStackView.Distribution

    // if axis is horizontal then this function will not be used,
    // if axis is vertical then for safe case handling estimated row height will be provided to the view at given stack index. Default is 0.0
    func estimatedRowHeight(stackIndex : StackIndex, stackView : UIView) -> CGFloat
    
    // if axis is vertical then this function will not be used,
    // if axis is horizontal then for safe case handling estimated row width will be provided to the view at given stack index. Default is 0.0
    func estimatedRowWidth(stackIndex : StackIndex, stackView : UIView) -> CGFloat
    
    
    // view for that particular row in section, default is nil
    func customViewForSectionHeaderInSection( section : Int, stackView : UIView) -> UIView?

    // if axis is horizontal then this function will not be used,
    // if axis is vertical then for safe case handling estimated row height will be provided to the view at given stack index. Default is 0.0
    func estimatedSectionHeaderHeight(section : Int, stackView : UIView) -> CGFloat
    
    // if axis is vertical then this function will not be used,
    // if axis is horizontal then for safe case handling estimated row width will be provided to the view at given stack index. Default is 0.0
    func estimatedSectionHeaderWidth(section : Int, stackView : UIView) -> CGFloat

    
    // view for that particular row in section, default is nil
    func customViewForSectionFooterInSection( section : Int, stackView : UIView) -> UIView?
    
    // if axis is horizontal then this function will not be used,
    // if axis is vertical then for safe case handling estimated row height will be provided to the view at given stack index. Default is 0.0
    func estimatedSectionFooterHeight(section : Int, stackView : UIView) -> CGFloat
    
    // if axis is vertical then this function will not be used,
    // if axis is horizontal then for safe case handling estimated row width will be provided to the view at given stack index. Default is 0.0
    func estimatedSectionFooterWidth(section : Int, stackView : UIView) -> CGFloat


    // to set any margins for the complete section, top bottom left right. Default is .zero
    func insetsForBackgroundViewForSectionAtSection(section : Int, stackView : UIView) -> StackInset

    
    // return true will automatically calculate size of complete view from its contents and will disable scroll.
    // but if return is true then in case of vertical axis you should not set any height constraint to the customStackView, in case of horizontal axis you should not set any width constraint to the customStackView. In nib you can set height/width contraint and set true to "remove at build time" or set it's priority to 1.
    // If you are returning true here, then we can use CustomStackView as a Label, it will be needing just two constraints Leading and Top. Rest can be added but not neccessary.
    // Default is false
    func shouldAutoPopulateSizeFromItsContentSize(stackView : UIView) -> Bool
    
    
    func isScrollViewBounce(stackView : UIView) -> Bool
    
    func isScrollViewClipToBounds(stackView : UIView) -> Bool

    func isShowsHorizontalScrollIndicator(stackView : UIView) -> Bool
    
    func isShowsVerticalScrollIndicator(stackView : UIView) -> Bool
    
    func minimumInterRowsSpacing(in section: Int, stackView : UIView) -> CGFloat
    func minimumInterSectionsSpacing(stackView : UIView) -> CGFloat
    
    //func getSelector
    
    func customStackViewBaseModelForRowAtStackIndex( stackIndex : StackIndex, stackView : UIView) -> CustomStackViewBaseModel?
    func customStackViewBaseModelForSectionBackgroundViewAtSection( section : Int, stackView : UIView) -> CustomStackViewBaseModel?
    func customStackViewBaseModelForSectionHeaderViewAtSection( section : Int, stackView : UIView) -> CustomStackViewBaseModel?
    func customStackViewBaseModelForSectionFooterViewAtSection( section : Int, stackView : UIView) -> CustomStackViewBaseModel?
}

public extension StackViewDataSource {
    func axisForStackView(stackView : UIView) -> NSLayoutConstraint.Axis{
        return .vertical
    }
    
    func alignmentForSection(section : Int, stackView : UIView) -> UIStackView.Alignment{
        return .fill
    }
    
    func distributionForSection(section : Int, stackView : UIView) -> UIStackView.Distribution{
        return .fill
    }

    func numberOfSections(in stackView : UIView) -> Int?{
        return 1
    }
    
    func backgroundViewForSectionAtSection(section : Int, stackView : UIView) -> UIView {
        let bgView = UIView()
        bgView.frame = stackView.bounds
        bgView.backgroundColor = .clear
        return bgView
    }
    func estimatedRowHeight(stackIndex : StackIndex, stackView : UIView) -> CGFloat{
        return 0.0
    }
    func estimatedRowWidth(stackIndex : StackIndex, stackView : UIView) -> CGFloat{
        return 0.0
    }
    func customViewForSectionHeaderInSection( section : Int, stackView : UIView) -> UIView?{
        return nil
    }
    func estimatedSectionHeaderHeight(section : Int, stackView : UIView) -> CGFloat{
        return 0.0
    }
    func estimatedSectionHeaderWidth(section : Int, stackView : UIView) -> CGFloat{
        return 0.0
    }
    
    func customViewForSectionFooterInSection( section : Int, stackView : UIView) -> UIView?{
        return nil
    }
    func estimatedSectionFooterHeight(section : Int, stackView : UIView) -> CGFloat{
        return 0.0
    }
    func estimatedSectionFooterWidth(section : Int, stackView : UIView) -> CGFloat{
        return 0.0
    }

    func insetsForBackgroundViewForSectionAtSection(section : Int, stackView : UIView) -> StackInset {
        return .zero
    }
    
    func shouldAutoPopulateSizeFromItsContentSize(stackView : UIView) -> Bool{
        return false
    }
    
    func isScrollViewBounce(stackView : UIView) -> Bool{
        return true
    }
    
    func isShowsHorizontalScrollIndicator(stackView : UIView) -> Bool{
        return true
    }
    
    func isShowsVerticalScrollIndicator(stackView : UIView) -> Bool{
        return true
    }
    
    func isScrollViewClipToBounds(stackView : UIView) -> Bool{
        return true
    }
    
    func minimumInterRowsSpacing(in section: Int, stackView : UIView) -> CGFloat{
        return 0.0
    }
    func minimumInterSectionsSpacing(stackView : UIView) -> CGFloat{
        return 0.0
    }
    func customStackViewBaseModelForRowAtStackIndex( stackIndex : StackIndex, stackView : UIView) -> CustomStackViewBaseModel? {
        return nil
    }
    func customStackViewBaseModelForSectionBackgroundViewAtSection( section : Int, stackView : UIView) -> CustomStackViewBaseModel?{
        return nil
    }
    func customStackViewBaseModelForSectionHeaderViewAtSection( section : Int, stackView : UIView) -> CustomStackViewBaseModel?{
        return nil
    }
    func customStackViewBaseModelForSectionFooterViewAtSection( section : Int, stackView : UIView) -> CustomStackViewBaseModel?{
        return nil
    }
}
