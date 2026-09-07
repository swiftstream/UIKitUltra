#if os(macOS) || os(iOS) || os(tvOS)
#if !os(macOS)
import UIKit

public enum TextFieldContentType {
    case name, namePrefix, givenName, middleName, familyName, nameSuffix, nickname
    case jobTitle, organizationName
    case location, fullStreetAddress, streetAddressLine1, streetAddressLine2, addressCity
    case addressState, addressCityAndState, sublocality, countryName, postalCode
    case telephoneNumber, emailAddress, URL, creditCardNumber
    case username, password
    case newPassword, oneTimeCode
    
    @available(iOS 10.0, *)
    var type: UITextContentType? {
        switch self {
        case .name:
            return .name
        case .namePrefix:
            return .namePrefix
        case .givenName:
            return .givenName
        case .middleName:
            return .middleName
        case .familyName:
            return .familyName
        case .nameSuffix:
            return .nameSuffix
        case .nickname:
            return .nickname
        case .jobTitle:
            return .jobTitle
        case .organizationName:
            return .organizationName
        case .location:
            return .location
        case .fullStreetAddress:
            return .fullStreetAddress
        case .streetAddressLine1:
            return .streetAddressLine1
        case .streetAddressLine2:
            return .streetAddressLine2
        case .addressCity:
            return .addressCity
        case .addressState:
            return .addressState
        case .addressCityAndState:
            return .addressCityAndState
        case .sublocality:
            return .sublocality
        case .countryName:
            return .countryName
        case .postalCode:
            return .postalCode
        case .telephoneNumber:
            return .telephoneNumber
        case .emailAddress:
            return .emailAddress
        case .URL:
            return .URL
        case .creditCardNumber:
            return .creditCardNumber
        case .username:
            if #available(iOS 11.0, *) {
                return .username
            } else {
                return nil
            }
        case .password:
            if #available(iOS 11.0, *) {
                return .password
            } else {
                return nil
            }
        case .newPassword:
            if #available(iOS 12.0, *) {
                return .newPassword
            } else {
                return nil
            }
        case .oneTimeCode:
            if #available(iOS 12.0, *) {
                return .oneTimeCode
            } else {
                return nil
            }
        }
    }
}
#endif
#endif
