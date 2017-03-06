//
//  RulerWithLineNumbers.swift
//  Metaltoy
//
//  Created by Chris Wood on 27/02/2017.
//  Copyright © 2017 Interealtime. All rights reserved.
//

import Cocoa

class RulerWithLineNumbers: NSRulerView {

	override init(scrollView: NSScrollView?, orientation: NSRulerOrientation) {
		super.init(scrollView: scrollView, orientation: orientation)
		
		ruleThickness = 40.0
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ dirtyRect: NSRect) {
//		Swift.print("Draw dirty rect")
		super.draw(dirtyRect)
	}
	
	override func drawMarkers(in rect: NSRect) {
//		Swift.print("Draw markers")
		super.drawMarkers(in: rect)
	}
	
	override func drawHashMarksAndLabels(in rect: NSRect) {
//		Swift.print("Draw hash marks and labels")
		guard let view = clientView as! NSTextView? else { return }
		
		if view.string?.characters.count == 0 { return }
		let textString = view.string! as NSString
		
		let insetHeight = view.textContainerInset.height
		let relativePoint = self.convert(NSZeroPoint, from: view)
		
		let lineNumberAttributes = view.textStorage!.attributes(at: 0, effectiveRange: nil)
		
		//		lineNumberAttributes[NSForegroundColorAttributeName] = self.textColor;
		let visibleGlyphRange = view.layoutManager?.glyphRange(forBoundingRect: view.visibleRect, in: view.textContainer!)
		
		let firstVisibleGlyphCharacterIndex = view.layoutManager?.characterIndexForGlyph(at: (visibleGlyphRange?.location)!)
		
		var lineNumber = countNewLinesIn(string: textString, location: 0, length: firstVisibleGlyphCharacterIndex!)
		
		var glyphIndexForStringLine = visibleGlyphRange?.location;
		
		while (glyphIndexForStringLine! < NSMaxRange(visibleGlyphRange!)) {
			// range of current line in the string
			let characterRangeForStringLine = textString.lineRange(for: NSRange(location: (view.layoutManager?.characterIndexForGlyph(at: glyphIndexForStringLine!))!, length: 0))
			
			let glyphRangeForStringLine = view.layoutManager?.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)
			
			var glyphIndexForGlyphLine = glyphIndexForStringLine;
			var glyphLineCount = 0;
			
			while (glyphIndexForGlyphLine! < NSMaxRange(glyphRangeForStringLine!)) {
				// check if the current line in the string spread across several lines of glyphs
				var effectiveRange = NSMakeRange(0, 0);
				
				// range of current "line of glyphs". If a line is wrapped then it will have more than one "line of glyphs"
				var lineRect = view.layoutManager?.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine!, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)
				
				// compute Y for line number
				let y = ceil(NSMinY(lineRect!) + relativePoint.y + insetHeight);
				lineRect?.origin.y = y;
				
				// draw line number only if string does not spread across several lines
				if (glyphLineCount == 0) {
					drawLineNumberInRect(lineNumber: lineNumber, lineRect: lineRect!, attributes: lineNumberAttributes, ruleThickness: ruleThickness)
				}
				
				// move to next glyph line
				glyphLineCount += 1
				glyphIndexForGlyphLine = NSMaxRange(effectiveRange);
			}
			
			glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine!);
			lineNumber += 1
		}
	}
	
	func countNewLinesIn(string: NSString, location: Int, length: Int) -> Int {
		return string.substring(to: length).components(separatedBy: CharacterSet.newlines).count
	}
	
	func drawLineNumberInRect(lineNumber: Int, lineRect: NSRect, attributes: [String: Any], ruleThickness: CGFloat) {
		let string = String(lineNumber)
		let attString = NSAttributedString(string: string, attributes: attributes)
		let x = ruleThickness - 5.0 - attString.size().width
		
		let font = attributes[NSFontAttributeName] as! NSFont
		
		var lr = lineRect
		lr.origin.x = x;
		lr.origin.y += font.ascender
		
		attString.draw(with: lr, options: NSStringDrawingOptions())
	}
}
