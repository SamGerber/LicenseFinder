require_relative '../../support/feature_helper'

describe "Elm Dependencies" do
  # As an Elm developer
  # I want to be able to manage Elm dependencies

  let(:elm_developer) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    LicenseFinder::TestingDSL::ElmProject.create
    elm_developer.run_license_finder
    expect(elm_developer).to be_seeing_line "elm-lang/core, 0.6.1, MIT"
  end
end
