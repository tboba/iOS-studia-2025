//
//  zadanie7UITests.swift
//  zadanie7UITests
//
//  Created by Tymoteusz on 1/29/26.
//

import XCTest

final class zadanie7UITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func testTabBarExists() throws {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.exists, "Tab bar should exist")
    }
    
    @MainActor
    func testTabBarHasFiveTabs() throws {
        let tabBar = app.tabBars.firstMatch
        let tabButtons = tabBar.buttons
        XCTAssertEqual(tabButtons.count, 5, "Tab bar should have 5 tabs")
    }
    
    @MainActor
    func testCategoriesTabExists() throws {
        let categoriesTab = app.tabBars.buttons["Categories"]
        XCTAssertTrue(categoriesTab.exists, "Categories tab should exist")
    }
    
    @MainActor
    func testProductsTabExists() throws {
        let productsTab = app.tabBars.buttons["Products"]
        XCTAssertTrue(productsTab.exists, "Products tab should exist")
    }
    
    @MainActor
    func testCartTabExists() throws {
        let cartTab = app.tabBars.buttons["Cart"]
        XCTAssertTrue(cartTab.exists, "Cart tab should exist")
    }
    
    @MainActor
    func testOrdersTabExists() throws {
        let ordersTab = app.tabBars.buttons["Orders"]
        XCTAssertTrue(ordersTab.exists, "Orders tab should exist")
    }
    
    @MainActor
    func testUserTabExists() throws {
        let userTab = app.tabBars.buttons["User"]
        XCTAssertTrue(userTab.exists, "User tab should exist")
    }
    
    @MainActor
    func testUserTabShowsLoginView() throws {
        app.tabBars.buttons["User"].tap()
        
        let welcomeText = app.staticTexts["Welcome Back"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 3),
                       "Should display 'Welcome Back' text")
    }
    
    @MainActor
    func testLoginViewHasSignInSubtitle() throws {
        app.tabBars.buttons["User"].tap()
        
        let subtitle = app.staticTexts["Sign in to continue shopping"]
        XCTAssertTrue(subtitle.waitForExistence(timeout: 3),
                       "Should display the login subtitle")
    }
    
    @MainActor
    func testLoginViewHasUsernameField() throws {
        app.tabBars.buttons["User"].tap()
        
        let usernameField = app.textFields["Enter username"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 3),
                       "Username field should exist")
    }
    
    @MainActor
    func testLoginViewHasPasswordField() throws {
        app.tabBars.buttons["User"].tap()
        
        let passwordField = app.secureTextFields["Enter password"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 3),
                       "Password field should exist")
    }
    
    @MainActor
    func testLoginViewHasSignInButton() throws {
        app.tabBars.buttons["User"].tap()
        
        let signInButton = app.buttons["SIGN IN"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 3),
                       "SIGN IN button should exist")
    }
    
    @MainActor
    func testLoginViewHasOrDivider() throws {
        app.tabBars.buttons["User"].tap()
        
        let orText = app.staticTexts["or"]
        XCTAssertTrue(orText.waitForExistence(timeout: 3),
                       "Should display 'or' separator text")
    }
    
    @MainActor
    func testLoginViewHasSignUpLink() throws {
        app.tabBars.buttons["User"].tap()
        
        let signUpText = app.staticTexts["SIGN UP"]
        XCTAssertTrue(signUpText.waitForExistence(timeout: 3),
                       "SIGN UP link should exist")
    }
    
    @MainActor
    func testLoginViewHasNoAccountText() throws {
        app.tabBars.buttons["User"].tap()
        
        let noAccountText = app.staticTexts["Don't have an account?"]
        XCTAssertTrue(noAccountText.waitForExistence(timeout: 3),
                       "'Don't have an account?' text should exist")
    }
    
    @MainActor
    func testNavigationToRegistration() throws {
        app.tabBars.buttons["User"].tap()
        
        let signUpButton = app.staticTexts["SIGN UP"]
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 3))
        signUpButton.tap()
        
        let createAccountText = app.staticTexts["Create Account"]
        XCTAssertTrue(createAccountText.waitForExistence(timeout: 3),
                       "Should display 'Create Account' text")
    }
    
    @MainActor
    func testRegistrationHasRegisterSubtitle() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let subtitle = app.staticTexts["Register to start shopping"]
        XCTAssertTrue(subtitle.waitForExistence(timeout: 3),
                       "Should display the registration subtitle")
    }
    
    @MainActor
    func testRegistrationHasFirstNameField() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let firstNameField = app.textFields["Enter first name"]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 3),
                       "First Name field should exist")
    }
    
    @MainActor
    func testRegistrationHasLastNameField() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let lastNameField = app.textFields["Enter last name"]
        XCTAssertTrue(lastNameField.waitForExistence(timeout: 3),
                       "Last Name field should exist")
    }
    
    @MainActor
    func testRegistrationHasUsernameField() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let usernameField = app.textFields["Enter username"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 3),
                       "Username field should exist")
    }
    
    @MainActor
    func testRegistrationHasPasswordField() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let passwordField = app.secureTextFields["Enter password (min. 4 characters)"]
        XCTAssertTrue(passwordField.waitForExistence(timeout: 3),
                       "Password field should exist")
    }
    
    @MainActor
    func testRegistrationHasConfirmPasswordField() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let confirmField = app.secureTextFields["Re-enter password"]
        XCTAssertTrue(confirmField.waitForExistence(timeout: 3),
                       "Confirm Password field should exist")
    }
    
    @MainActor
    func testRegistrationHasSignUpButton() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let signUpButton = app.buttons["SIGN UP"]
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 3),
                       "SIGN UP button should exist in registration")
    }
    
    @MainActor
    func testRegistrationHasBackToLoginLink() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let loginText = app.staticTexts["LOG IN"]
        XCTAssertTrue(loginText.waitForExistence(timeout: 3),
                       "LOG IN link should exist in registration")
    }
    
    @MainActor
    func testRegistrationHasAlreadyHaveAccountText() throws {
        app.tabBars.buttons["User"].tap()
        app.staticTexts["SIGN UP"].tap()
        
        let text = app.staticTexts["Already have an account?"]
        XCTAssertTrue(text.waitForExistence(timeout: 3),
                       "'Already have an account?' text should exist")
    }
    
    @MainActor
    func testCategoriesTabShowsSignInRequired() throws {
        app.tabBars.buttons["Categories"].tap()
        
        let signInText = app.staticTexts["Sign In Required"]
        XCTAssertTrue(signInText.waitForExistence(timeout: 3),
                       "Categories tab should require sign in")
    }
    
    @MainActor
    func testProductsTabShowsSignInRequired() throws {
        app.tabBars.buttons["Products"].tap()
        
        let signInText = app.staticTexts["Sign In Required"]
        XCTAssertTrue(signInText.waitForExistence(timeout: 3),
                       "Products tab should require sign in")
    }
    
    @MainActor
    func testCartTabShowsSignInRequired() throws {
        app.tabBars.buttons["Cart"].tap()
        
        let signInText = app.staticTexts["Sign In Required"]
        XCTAssertTrue(signInText.waitForExistence(timeout: 3),
                       "Cart tab should require sign in")
    }
    
    @MainActor
    func testOrdersTabShowsSignInRequired() throws {
        app.tabBars.buttons["Orders"].tap()
        
        let signInText = app.staticTexts["Sign In Required"]
        XCTAssertTrue(signInText.waitForExistence(timeout: 3),
                       "Orders tab should require sign in")
    }
    
    @MainActor
    func testSignInRequiredShowsMessage() throws {
        app.tabBars.buttons["Categories"].tap()
        
        let message = app.staticTexts["Please sign in to access this feature"]
        XCTAssertTrue(message.waitForExistence(timeout: 3),
                       "Sign in required message should exist")
    }
    
    @MainActor
    func testSignInRequiredShowsGoToUserTab() throws {
        app.tabBars.buttons["Categories"].tap()
        
        let goToUserText = app.staticTexts["Go to the User tab to sign in"]
        XCTAssertTrue(goToUserText.waitForExistence(timeout: 3),
                       "User tab hint should exist")
    }
    
    @MainActor
    func testTabSwitchingFromUserToCategories() throws {
        app.tabBars.buttons["User"].tap()
        let welcomeText = app.staticTexts["Welcome Back"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 3))
        
        app.tabBars.buttons["Categories"].tap()
        let signInText = app.staticTexts["Sign In Required"]
        XCTAssertTrue(signInText.waitForExistence(timeout: 3),
                       "After switching to Categories, Sign In Required should appear")
    }
    
    @MainActor
    func testTabSwitchingBackToUser() throws {
        app.tabBars.buttons["Categories"].tap()
        app.tabBars.buttons["User"].tap()
        
        let welcomeText = app.staticTexts["Welcome Back"]
        XCTAssertTrue(welcomeText.waitForExistence(timeout: 3),
                       "After returning to User, login view should appear")
    }
    
    @MainActor
    func testLoginFormUsernameFieldAcceptsInput() throws {
        app.tabBars.buttons["User"].tap()
        
        let usernameField = app.textFields["Enter username"]
        XCTAssertTrue(usernameField.waitForExistence(timeout: 3))
        usernameField.tap()
        usernameField.typeText("testuser")
        
        XCTAssertEqual(usernameField.value as? String, "testuser",
                        "Username field should accept typed text")
    }
    
    @MainActor
    func testLoginPersonIconExists() throws {
        app.tabBars.buttons["User"].tap()
        
        let personIcon = app.images["person.circle.fill"]
        XCTAssertTrue(personIcon.waitForExistence(timeout: 3),
                       "Person icon should exist on the login screen")
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
