//
//  LastNameField.swift
//  PrimerSDK
//
//  Created by Dario Carlomagno on 08/06/22.
//

#if canImport(UIKit)

import UIKit

class PrimerCountryField: PrimerCardFormFieldProtocol {
    
    internal static let theme: PrimerThemeProtocol = DependencyContainer.resolve()
    
    static func countryContainerViewFieldView(_ view: PrimerTextFieldView, openCountriesListPressed: @escaping PrimerAction) -> PrimerCustomFieldView {
        let countryFieldContainerView = PrimerCustomFieldView()
        countryFieldContainerView.fieldView = view
        countryFieldContainerView.placeholderText = Strings.CardFormView.CountryCode.label
        countryFieldContainerView.setup()
        countryFieldContainerView.tintColor = theme.input.border.color(for: .selected)
        if let countryView = view as? PrimerCountryFieldView {
            countryView.onOpenCountriesListPressed = openCountriesListPressed
        }
        return countryFieldContainerView
    }
    
    static func countryFieldViewWithDelegate(_ delegate: PrimerTextFieldViewDelegate?) -> PrimerCountryFieldView {
        let countryFieldView = PrimerCountryFieldView()
        countryFieldView.placeholder = Strings.CardFormView.CountryCode.placeholder
        countryFieldView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        countryFieldView.textColor = theme.input.text.color
        countryFieldView.delegate = delegate
        return countryFieldView
    }
}


#endif
