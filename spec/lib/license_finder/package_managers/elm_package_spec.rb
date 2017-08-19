require 'spec_helper'

module LicenseFinder
  describe ElmPackage do
    subject do
      described_class.new(
          "name" => "elm-lang/html",
          "version" => "2.0.0",
          "description" => "a description",
          "readme" => "a readme",
          "path" => "some/elm/package/path",
          "homepage" => "a homepage",
          "dependencies" => {
              "elm-lang/core" => {
                  "name" => "elm-lang/core",
                  "version" => "5.0.0 <= v < 6.0.0"
              },
              "elm-lang/virtual-dom" => {
                  "name" => "elm-lang/virtual-dom",
                  "version" => "2.0.0 <= v < 3.0.0"
              }
          }
      )
    end

    its(:name) { should == "elm-lang/html" }
    its(:version) { should == "2.0.0" }
    its(:summary) { should eq "" }
    its(:description) { should == "a description" }
    its(:homepage) { should == "a homepage" }
    its(:groups) { should == [] } # TODO: put devDependencies in 'dev' group?
    its(:children) { should == ["elm-lang/core", "elm-lang/virtual-dom"] }
    its(:install_path) { should eq "some/elm/package/path" }
    its(:package_manager) { should eq 'Elm' }

    describe '#license_names_from_spec' do
      let(:elm_package1) { {"name" => "elm_package1", "version" => "1", "license" => "MIT"} }
      let(:elm_package2) { {"name" => "elm_package2", "version" => "2", "licenses" => [{"type" => "BSD"}]} }
      let(:elm_package3) { {"name" => "elm_package3", "version" => "3", "license" => {"type" => "PSF"}} }
      let(:elm_package4) { {"name" => "elm_package4", "version" => "4", "licenses" => ["MIT"]} }
      let(:misdeclared_elm_package) { {"name" => "elm_package0", "version" => "0", "licenses" => {"type" => "MIT"}} }

      it 'finds the license for both license structures' do
        package = ElmPackage.new(elm_package1)
        expect(package.license_names_from_spec).to eq ["MIT"]

        package = ElmPackage.new(elm_package2)
        expect(package.license_names_from_spec).to eq ["BSD"]

        package = ElmPackage.new(elm_package3)
        expect(package.license_names_from_spec).to eq ["PSF"]

        package = ElmPackage.new(elm_package4)
        expect(package.license_names_from_spec).to eq ["MIT"]

        package = ElmPackage.new(misdeclared_elm_package)
        expect(package.license_names_from_spec).to eq ["MIT"]
      end
    end
  end
end
