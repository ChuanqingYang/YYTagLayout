// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI

@available(iOS 16.0, *)
public struct YYTagLayout: Layout {
    
    public var alignment: Alignment = .center
    public var horizontalSpacing: CGFloat = 10
    public var verticalSpacing: CGFloat = 10
    
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        let rows = generateRows(maxWidth, proposal, subviews)
        
        /// find max height in row and add it to the total ``height`` of the view
        for (index, row) in rows.enumerated() {
            if index == (rows.count - 1) {
                /// last row has no spacing at the bottom
                height += row.maxHeight(proposal)
            }else {
                height += row.maxHeight(proposal) + verticalSpacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            
            /// changing origin x based on ``alignment``???
            let leading: CGFloat = bounds.maxX - maxWidth
            /// the origin for trailing can be easily caculated by subtracting
            ///  the total row width from the maximum width.
            ///  since the trailing origin is found,it's obvious that half of this value will lead to the centre origin
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                
                if view == row.last {
                    return partialResult + width
                }
                
                return partialResult + width + horizontalSpacing
            })
            
            let center = (leading + trailing) / 2
            
            /// reset origin.x to zero for each row
            origin.x = (alignment == .leading ? leading : alignment == .trailing ? trailing : center)
            
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                /// updating origin x
                origin.x += (viewSize.width + horizontalSpacing)
            }
            
            origin.y += (row.maxHeight(proposal) + verticalSpacing)
        }
    }
    
    func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        /// Origin
        var origin = CGRect.zero.origin
        
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            /// pushing to a new row
            if (origin.x + viewSize.width + horizontalSpacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                /// reset origin.x
                origin.x = 0
                /// new line first item
                row.append(view)
                origin.x += viewSize.width + horizontalSpacing
            }else {
                /// adding item to the row
                row.append(view)
                origin.x += viewSize.width + horizontalSpacing
            }
        }
        
        /// checking for any exhaust row
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
    }
}

@available(iOS 16.0, *)
extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
