//
//  CustomNavigationTitleView.swift
//  OnsaTube
//
//  Created by Adem Özsayın on 24.06.2024.
//

import SwiftUI

public extension View {
    @ViewBuilder func customNavigationTitleWithRightIcon<Content: View>(@ViewBuilder _ rightIcon: @escaping () -> Content) -> some View {
        overlay(content: {
            CustomNavigationTitleView(rightIcon: rightIcon)
                .frame(width: 0, height: 0)
        })
    }
}
public struct CustomNavigationTitleView<RightIcon: View>: UIViewControllerRepresentable {
    @ViewBuilder public var rightIcon: () -> RightIcon
    
    public func makeUIViewController(context: Context) -> UIViewController {
        return ViewControllerWrapper(rightContent: rightIcon)
    }
    
    class ViewControllerWrapper: UIViewController {
        var rightContent: () -> RightIcon
        
        init(rightContent: @escaping () -> RightIcon) {
            self.rightContent = rightContent
            super.init(nibName: nil, bundle: nil)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            guard let navigationController = self.navigationController, let navigationItem = navigationController.visibleViewController?.navigationItem else { return }
            
            let contentView = UIHostingController(rootView: rightContent())
            contentView.view.backgroundColor = .clear
            
            // https://github.com/sebjvidal/UINavigationItem-LargeTitleAccessoryView-Demo
            navigationItem.perform(Selector(("_setLargeTitleAccessoryView:")), with: contentView.view)
            navigationItem.setValue(false, forKey: "_alignLargeTitleAccessoryViewToBaseline")
            navigationController.navigationBar.prefersLargeTitles = true
            
            super.viewWillAppear(animated)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
