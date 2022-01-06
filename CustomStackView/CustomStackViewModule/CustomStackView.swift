//
//  CustomStackView.swift
//  TestSwift
//
//  Created by Neeraj Gupta on 27/02/20.
//  Copyright © 2020 Neeraj Gupta. All rights reserved.
//

import UIKit

// section background view, section header view, section footer view
private enum CustomStackSubViewType : Int, CaseIterable {
    case backgroundView = 1
    case sectionHeaderView = 2
    case sectionFooterView = 3
    static func getCount() -> Int {
        return CustomStackSubViewType.allCases.count
    }
}

private let NumberOfInBetweenViews : Int = CustomStackSubViewType.getCount()

public class CustomStackView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // intentioanlly created this outlet as strong, becuase while changing isActive to false outlet get released from the memory that's why strong reference, discussed with Haroon.
    @IBOutlet var customWidthConstraint: NSLayoutConstraint!
    @IBOutlet var customHeightConstraint: NSLayoutConstraint!
    private var constantMultiplier : Int = 60000
    private var constantInitialValue : Int = 0
    private var maxPossibleSubviewTag : Int = 60000

    public override func awakeFromNib() {
        super.awakeFromNib()
      //  scrollView.backgroundColor = ThemeManager.shared.getColorTheme().background
    }
    
    private weak var dataSource : StackViewDataSource?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        let bundle = Bundle(for: self.classForCoder)
        bundle.loadNibNamed("CustomStackView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        configureAllViews()
    }

    private func configureAllViews(){
        mainStackView.removeAllArrangedSubviews()
        
        guard let dataSrc = dataSource else{
            return
        }
        
        let stackViewAxis = dataSrc.axisForStackView(stackView: self)

        mainStackView.axis = stackViewAxis
        mainStackView.distribution = .fill
        mainStackView.alignment = .fill
        mainStackView.spacing = dataSrc.minimumInterSectionsSpacing(stackView: self)
        setScrollViewScrollDirection()
        
        if let totalNumberOfSections = dataSrc.numberOfSections(in: self), totalNumberOfSections > 0{
            constantMultiplier = totalNumberOfSections + CustomStackSubViewType.getCount()
            configureConstantInitialValue()
            var contraintType : NSLayoutConstraint.Attribute = .height
            if stackViewAxis == .horizontal {
                contraintType = .width
            }

            for sectionIndex in 0..<totalNumberOfSections {
                
                var sectionStackIsNonEmpty : Bool = false
                
                let completeSectionStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 10))
                completeSectionStackView.axis = stackViewAxis
                completeSectionStackView.alignment = .fill
                completeSectionStackView.distribution = .fill
                completeSectionStackView.spacing = 0.0

                let sectionBackgroundView = dataSrc.backgroundViewForSectionAtSection(section: sectionIndex, stackView: self)
                
                if let sectionHeaderView = dataSrc.customViewForSectionHeaderInSection(section: sectionIndex, stackView: self) {
                    var estimatedLayout = dataSrc.estimatedSectionHeaderHeight(section: sectionIndex, stackView: self)
                    if stackViewAxis == .horizontal {
                        estimatedLayout = dataSrc.estimatedSectionHeaderWidth(section: sectionIndex, stackView: self)
                    }
                    let constraint = NSLayoutConstraint(item: sectionHeaderView, attribute: contraintType, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: estimatedLayout)
                    constraint.priority = UILayoutPriority(251)
                    constraint.isActive = true
                    sectionHeaderView.tag = getTagForAddedSubView(section: sectionIndex, viewType: .sectionHeaderView)
                    sectionStackIsNonEmpty = true
                    completeSectionStackView.addArrangedSubview(sectionHeaderView)
                }

                if let totalNumberOfRows = dataSrc.numberOfRowsInSection(in: sectionIndex, stackView: self), totalNumberOfRows > 0{
                    let rowStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: 10))
                    rowStackView.axis = stackViewAxis
                    rowStackView.alignment = dataSrc.alignmentForSection(section: sectionIndex, stackView: self)
                    rowStackView.distribution = dataSrc.distributionForSection(section: sectionIndex, stackView: self)
                    rowStackView.spacing = dataSrc.minimumInterRowsSpacing(in : sectionIndex, stackView: self)

                    for rowIndex in 0..<totalNumberOfRows {
                        let stackIndex = StackIndex(row: rowIndex, section: sectionIndex)
                        let rowView = dataSrc.viewForRowAtStackIndex(stackIndex: stackIndex, stackView: self)
                        var estimatedLayout = dataSrc.estimatedRowHeight(stackIndex: stackIndex, stackView: self)
                        if stackViewAxis == .horizontal {
                            estimatedLayout = dataSrc.estimatedRowWidth(stackIndex: stackIndex, stackView: self)
                        }
                        let constraint = NSLayoutConstraint(item: rowView, attribute: contraintType, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: estimatedLayout)
                        constraint.priority = UILayoutPriority(251)
                        constraint.isActive = true
                        rowView.tag = getTagForStackIndex(stackIndex: stackIndex)
                        if maxPossibleSubviewTag < rowView.tag {
                            maxPossibleSubviewTag = rowView.tag
                        }
                        rowStackView.addArrangedSubview(rowView)
                    }
                    sectionBackgroundView.addSubview(rowStackView)
                    
                    sectionBackgroundView.frame = CGRect(x: 0, y: 0, width: sectionBackgroundView.frame.width, height: rowStackView.bounds.height)
                    rowStackView.translatesAutoresizingMaskIntoConstraints = false
                    
                    let stackInset = dataSrc.insetsForBackgroundViewForSectionAtSection(section: sectionIndex, stackView: self)
                    
                    NSLayoutConstraint(item: rowStackView, attribute: .leading, relatedBy: .equal, toItem: sectionBackgroundView, attribute: .leading, multiplier: 1.0, constant: stackInset.leading).isActive = true
                    NSLayoutConstraint(item: rowStackView, attribute: .trailing, relatedBy: .equal, toItem: sectionBackgroundView, attribute: .trailing, multiplier: 1.0, constant: stackInset.trailing).isActive = true
                    NSLayoutConstraint(item: rowStackView, attribute: .top, relatedBy: .equal, toItem: sectionBackgroundView, attribute: .top, multiplier: 1.0, constant: stackInset.top).isActive = true
                    NSLayoutConstraint(item: rowStackView, attribute: .bottom, relatedBy: .equal, toItem: sectionBackgroundView, attribute: .bottom, multiplier: 1.0, constant: stackInset.bottom).isActive = true
                    sectionBackgroundView.tag = getTagForAddedSubView(section: sectionIndex, viewType: .backgroundView)

                    sectionStackIsNonEmpty = true
                    completeSectionStackView.addArrangedSubview(sectionBackgroundView)
                }
                
                
                if let sectionFooterView = dataSrc.customViewForSectionFooterInSection(section: sectionIndex, stackView: self) {
                    var estimatedLayout = dataSrc.estimatedSectionFooterHeight(section: sectionIndex, stackView: self)
                    if stackViewAxis == .horizontal {
                        estimatedLayout = dataSrc.estimatedSectionFooterWidth(section: sectionIndex, stackView: self)
                    }
                    let constraint = NSLayoutConstraint(item: sectionFooterView, attribute: contraintType, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: estimatedLayout)
                    constraint.priority = UILayoutPriority(251)
                    constraint.isActive = true
                    sectionFooterView.tag = getTagForAddedSubView(section: sectionIndex, viewType: .sectionFooterView)

                    sectionStackIsNonEmpty = true
                    completeSectionStackView.addArrangedSubview(sectionFooterView)
                }

                if sectionStackIsNonEmpty {
                    mainStackView.addArrangedSubview(completeSectionStackView)
                }
            }
        }
    }
    
    private func getTagForAddedSubView(section : Int, viewType : CustomStackSubViewType) -> Int {
        return section*constantMultiplier + viewType.rawValue + constantInitialValue
    }

    private func getTagForStackIndex(stackIndex : StackIndex) -> Int {
        return (stackIndex.row*constantMultiplier) + stackIndex.section + (CustomStackSubViewType.getCount() + 1) + constantInitialValue
    }
    private func getSectionIndexForBgView(customView : UIView, viewType : CustomStackSubViewType) -> Int?{
        if !customView.isDescendant(of: mainStackView) {
            return nil
        }
        let customTag = customView.tag - viewType.rawValue - constantInitialValue
        if customTag%constantMultiplier == 0 {
            return customTag/constantMultiplier
        }
        else{
            return nil
        }
    }
    private func getStackIndexForCustomView(customView : UIView) -> StackIndex?{
        if !customView.isDescendant(of: mainStackView) {
            return nil
        }
        let customTag = (customView.tag - constantInitialValue ) % constantMultiplier
        if  CustomStackSubViewType(rawValue: customTag) != nil {
            return nil
        }
        let formulaTag = customView.tag - (CustomStackSubViewType.getCount() + 1) - constantInitialValue
        let row = formulaTag/constantMultiplier
        let section = formulaTag%constantMultiplier
        return StackIndex(row: row, section: section)
    }
    private func getViewForStackIndex(stackIndex : StackIndex) -> UIView?{
        let tag = getTagForStackIndex(stackIndex: stackIndex)
        return mainStackView.viewWithTag(tag)
    }
    private func getSectionBackgroundViewFor(section : Int) -> UIView?{
        let tag = getTagForAddedSubView(section: section, viewType: .backgroundView)
        return mainStackView.viewWithTag(tag)
    }
    private func getSectionHeaderViewFor(section : Int) -> UIView?{
        let tag = getTagForAddedSubView(section: section, viewType: .sectionHeaderView)
        return mainStackView.viewWithTag(tag)
    }
    private func getSectionFooterViewFor(section : Int) -> UIView?{
        let tag = getTagForAddedSubView(section: section, viewType: .sectionFooterView)
        return mainStackView.viewWithTag(tag)
    }

    private func setScrollViewScrollDirection(){
        let needContentSized = dataSource?.shouldAutoPopulateSizeFromItsContentSize(stackView: self) ?? false
        scrollView.bounces = dataSource?.isScrollViewBounce(stackView: self) ?? true
        scrollView.clipsToBounds = dataSource?.isScrollViewClipToBounds(stackView: self) ?? false
        let showsHorizontalScrollIndicator = dataSource?.isShowsHorizontalScrollIndicator(stackView: self) ?? true
        let showsVerticalScrollIndicator = dataSource?.isShowsVerticalScrollIndicator(stackView: self) ?? true
        scrollView.isScrollEnabled = !needContentSized
        
        if dataSource?.axisForStackView(stackView: self) == .vertical {
            
            scrollView.showsVerticalScrollIndicator = !needContentSized && showsVerticalScrollIndicator
            scrollView.alwaysBounceVertical = !needContentSized
            
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.alwaysBounceHorizontal = false
            
            if needContentSized {
                if #available(iOS 13.0, *){
                    customHeightConstraint.priority = UILayoutPriority(999)
                }
                customHeightConstraint.isActive = true
            }
            else{
                customHeightConstraint.isActive = false
            }
            if #available(iOS 13.0, *){
                customWidthConstraint.priority = UILayoutPriority(1000)
            }
            customWidthConstraint.isActive = true
        }
        else if dataSource?.axisForStackView(stackView: self) == .horizontal {
            scrollView.showsVerticalScrollIndicator = false
            scrollView.alwaysBounceVertical = false
            
            scrollView.showsHorizontalScrollIndicator = !needContentSized && showsHorizontalScrollIndicator
            scrollView.alwaysBounceHorizontal = !needContentSized
                        
            if needContentSized {
                if #available(iOS 13.0, *){
                    customWidthConstraint.priority = UILayoutPriority(999)
                }
                customWidthConstraint.isActive = true
            }
            else{
                customWidthConstraint.isActive = false
            }
            if #available(iOS 13.0, *){
                customHeightConstraint.priority = UILayoutPriority(1000)
            }
            customHeightConstraint.isActive = true
        }
    }
    
    private func configureConstantInitialValue(){
        func checkIfSuperviewIsCustomStackView() -> CustomStackView?{
            var customCheck: UIView? = self.superview
            while !(customCheck is CustomStackView) && customCheck != nil {
                customCheck = customCheck?.superview
            }
            return customCheck as? CustomStackView
        }
        if let superCustomStackView = checkIfSuperviewIsCustomStackView() {
            self.constantInitialValue = superCustomStackView.maxPossibleSubviewTag
        }
    }
    
}

public extension CustomStackView {
    func setStackViewDataSource(dataSource : StackViewDataSource?){
        self.dataSource = dataSource
        configureAllViews()
        reloadContentsOfAllViews()
    }
    func reloadAllData(){
        configureAllViews()
        reloadContentsOfAllViews()
    }
    
    func reloadViewDataAtIndex(stackIndex : StackIndex){
        guard let dataSrc = dataSource, let rowView = getViewForStackIndex(stackIndex: stackIndex), let rowBaseModel = dataSrc.customStackViewBaseModelForRowAtStackIndex(stackIndex: stackIndex, stackView: self) else{
            return
        }
        rowView.reloadCustomStackSubView(with: rowBaseModel)
    }

    func reloadViewsDataAtIndexes(stackIndexes : [StackIndex]){
        for stackIndex in stackIndexes {
            reloadViewDataAtIndex(stackIndex: stackIndex)
        }
    }
    
    func reloadCompleteSectionDataAtIndex( section : Int){
        guard let dataSrc = dataSource else{
            return
        }
        if let totalNumberOfSections = dataSrc.numberOfSections(in: self), totalNumberOfSections > 0{
            if section >= totalNumberOfSections {
                return
            }
            if let sectionBackgroundView = getSectionBackgroundViewFor(section: section), let sectionBaseModel = dataSrc.customStackViewBaseModelForSectionBackgroundViewAtSection(section: section, stackView: self) {
                sectionBackgroundView.reloadCustomStackSubView(with: sectionBaseModel)
            }

            if let sectionHeaderView = getSectionHeaderViewFor(section: section), let sectionBaseModel = dataSrc.customStackViewBaseModelForSectionHeaderViewAtSection(section: section, stackView: self) {
                sectionHeaderView.reloadCustomStackSubView(with: sectionBaseModel)
            }
            
            if let totalNumberOfRows = dataSrc.numberOfRowsInSection(in: section, stackView: self), totalNumberOfRows > 0{
                for rowIndex in 0..<totalNumberOfRows {
                    let stackIndex = StackIndex(row: rowIndex, section: section)
                    reloadViewDataAtIndex(stackIndex: stackIndex)
                }
            }
            if let sectionFooterView = getSectionFooterViewFor(section: section), let sectionBaseModel = dataSrc.customStackViewBaseModelForSectionFooterViewAtSection(section: section, stackView: self) {
                sectionFooterView.reloadCustomStackSubView(with: sectionBaseModel)
            }
        }
    }
    
    func reloadCompleteSectionsDataAtIndexes( sections : [Int]){
        for section in sections {
            reloadCompleteSectionDataAtIndex(section: section)
        }
    }

    func reloadContentsOfAllViews(){
        guard let dataSrc = dataSource else{
            return
        }
        if let totalNumberOfSections = dataSrc.numberOfSections(in: self), totalNumberOfSections > 0{
            for sectionIndex in 0..<totalNumberOfSections {
                reloadCompleteSectionDataAtIndex(section: sectionIndex)
            }
        }
    }
    func getSectionBackgroundViewFrom(section : Int) -> UIView?{
        return getSectionBackgroundViewFor(section: section)
    }
    func getSectionHeaderViewFrom(section : Int) -> UIView?{
        return getSectionHeaderViewFor(section: section)
    }
    func getSectionFooterViewFrom(section : Int) -> UIView?{
        return getSectionFooterViewFor(section: section)
    }

    func getSectionIndexForSectionBackgroundView(someView : UIView) -> Int?{
        return getSectionIndexForBgView(customView: someView, viewType: .backgroundView)
    }
    func getSectionIndexForSectionHeaderView(someView : UIView) -> Int?{
        return getSectionIndexForBgView(customView: someView, viewType: .sectionHeaderView)
    }
    func getSectionIndexForSectionFooterView(someView : UIView) -> Int?{
        return getSectionIndexForBgView(customView: someView, viewType: .sectionFooterView)
    }

    func getViewFrom(index : StackIndex) -> UIView?{
        return getViewForStackIndex(stackIndex: index)
    }
    
    func setViewHiddenAt(index : StackIndex, hidden : Bool, animation : Bool){
        let view = getViewForStackIndex(stackIndex: index)
        UIView.animate(withDuration: animation ? 0.5 : 0.0) {[weak self] in
            view?.isHidden = hidden
            self?.layoutIfNeeded()
        }
    }
    func getStackIndexForView(someView : UIView) -> StackIndex?{
        return getStackIndexForCustomView(customView: someView)
    }
    
    func getScrollViewContentSize() -> CGSize {
        return scrollView.contentSize
    }
    
    func updateScrollViewContentEdgeInsets(edgeInsets : UIEdgeInsets){
        scrollView.contentInset = edgeInsets
    }
    
    func setScrollViewDelegate(scrollViewDelegate : UIScrollViewDelegate) {
        scrollView.delegate = scrollViewDelegate
    }
    func scrollScrollViewRectToVisible(rect : CGRect, animated: Bool){
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
    func setScrollViewContentOffset(contentOffset : CGPoint, animated: Bool){
        scrollView.setContentOffset(contentOffset, animated: animated)
    }
    
    func scrollAt(index: StackIndex, animation: Bool) {
        guard let view = getViewForStackIndex(stackIndex: index) else {
            return
        }
        scrollView.scrollRectToVisible(view.frame, animated: animation)
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
