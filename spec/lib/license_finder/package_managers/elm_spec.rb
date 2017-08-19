require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Elm do
    let(:root) { '/fake-elm-project' }
    let(:elm) { Elm.new project_path: Pathname.new(root) }

    it_behaves_like 'a PackageManager'

    let(:elm_package_json) do
      {
        dependencies: {
            'elm-dependency' => '1.3.3.7',
            'elm-dependency2' => '4.2'
        },
        devDependencies: {
            'elm-dependency3' => '4.2'
        }
      }.to_json
    end

    let(:dependency_json) do
      <<-JSON
          {
            "dependencies": {
              "elm-dependency": {
                "name": "elm-dependency",
                "version": "1.3.3.7",
                "description": "description",
                "readme": "readme",
                "path": "/path/to/thing",
                "dependencies": {
                  "elm-dependency1-1": {
                    "name": "elm-dependency1-1",
                    "version": "1-1"
                  }
                }
              },
              "elm-dependency2": {
                "name": "elm-dependency2",
                "version": "4.2",
                "description": "description2",
                "readme": "readme2",
                "path": "/path/to/thing2",
                "dependencies": {
                  "elm-dependency2-1": {
                    "name": "elm-dependency2-1",
                    "version": "2-1",
                    "dependencies": {
                      "elm-dependency1-1": {
                        "name": "elm-dependency1-1",
                        "version": "1-1"
                      }
                    }
                  }
                }
              },
              "elm-dependency3": {
                "name": "elm-dependency3",
                "version": "4.2",
                "description": "description3",
                "readme": "readme3",
                "path": "/path/to/thing3",
                "dependencies": {
                  "elm-dependency1-1": {
                    "name": "elm-dependency1-1",
                    "version": "1-1"
                  },
                 "elm-dependency3-1": {
                    "name": "elm-dependency3-1",
                    "version": "3-1"
                  }
                }
              }
            },
            "notADependency": {
              "elm-dependency6": {
                "name": "dep6js",
                "version": "4.2",
                "description": "description6",
                "readme": "readme6",
                "path": "/path/to/thing6"
              }
            }
          }
      JSON
    end

    describe '.current_packages' do
      include FakeFS::SpecHelpers
      before do
        Elm.instance_variable_set(:@modules, nil)
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, 'elm-package.json'), elm_package_json)
        allow(elm).to receive(:run_command_with_tempfile_buffer).and_return ['', JSON.parse(dependency_json), true]
      end

      it 'fetches data from elm' do
        current_packages = elm.current_packages
        expect(current_packages.map(&:name)).to eq(%w(elm-dependency elm-dependency1-1 elm-dependency2 elm-dependency2-1 elm-dependency3 elm-dependency3-1))
      end

      it 'finds the groups for dependencies' do
        current_packages = elm.current_packages
        expect(current_packages.find { |p| p.name == 'elm-dependency' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'elm-dependency1-1' }.groups).to eq(%w(dependencies devDependencies))
        expect(current_packages.find { |p| p.name == 'elm-dependency2' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'elm-dependency2-1' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'elm-dependency3' }.groups).to eq(['devDependencies'])
        expect(current_packages.find { |p| p.name == 'elm-dependency3-1' }.groups).to eq(['devDependencies'])
      end

      it 'fails when command fails' do
        allow(elm).to receive(:run_command_with_tempfile_buffer).with(/elm/).and_return('Some error', nil, false).once
        expect { elm.current_packages }.to raise_error(RuntimeError)
      end

      it 'does not fail when command fails but produces output' do
        allow(elm).to receive(:run_command_with_tempfile_buffer).and_return ['', {'foo' => 'bar'}, false]
        silence_stderr { elm.current_packages }
      end
    end
  end
end
