# frozen_string_literal: true

require "application_system_test_case"

module Admin
  class DocumentLicensedAccessesTest < ApplicationSystemTestCase
    include Devise::Test::IntegrationHelpers

    setup do
      @admin = users(:admin)
      sign_in @admin
      @document = documents(:one)
      @document_licensed_access = document_licensed_accesses(:one)
    end

    test "visiting the index" do
      visit admin_document_licensed_accesses_url
      assert_selector "h1", text: "Document Licensed Access"
    end

    test "creating a Document Licensed Access" do
      visit admin_document_licensed_accesses_url
      click_on "New Licensed Access"

      fill_in "Friendlier", with: @document.friendlier_id
      fill_in "Institution code", with: "2"
      fill_in "Access url", with: "https://example.com"
      click_on "Create Document licensed access"

      assert_text "Document licensed access was successfully created"
    end

    test "updating a Document Licensed Access" do
      visit admin_document_licensed_accesses_url
      click_on "Edit", match: :first

      fill_in "Access url", with: "https://updated-example.com"
      click_on "Update Document licensed access"

      assert_text "Document licensed access was successfully updated"
    end

    test "destroying a Document Licensed Access" do
      visit admin_document_licensed_accesses_url
      page.accept_confirm do
        click_on "Delete", match: :first
      end

      assert_text "Document licensed access was successfully destroyed"
    end
  end
end 