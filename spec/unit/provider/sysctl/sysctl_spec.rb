require 'puppet'
require 'fileutils'
require 'mocha'

RSpec.configure do |config|
  config.mock_with :mocha
end

describe 'The sysctl provider for the sysctl type' do
  let(:test_file) { File.join('/tmp', Time.now.to_i.to_s,'sysctl.conf') }
  let(:resource) { Puppet::Type::Sysctl.new({:path => test_file}) }
  subject { Puppet::Type.type(:sysctl).provider(:sysctl).new(resource) }
  after :each do
    FileUtils.rm_rf(File.dirname(test_file)) if File.exists?(test_file)
  end

  it 'should ensure that the git directory does not exist initially' do
    subject.exists?.should == false
  end

  it 'should ensure that a git directory does exist' do
    FileUtils.mkdir_p(test_dir)
    subject.exists?.should == true
  end

  it 'should clone the thing when run and the directory does not exist' do
    resource[:source] = source
    subject.expects(:git).with('clone', source, test_dir)
    subject.create
  end

  it 'should init thing when run and the directory does not exist' do
    subject.expects(:git).with('init','-q',test_dir)
    subject.create
  end

  it 'should trash the thing when destroyed' do
    FileUtils.expects(:rm_f).with(test_dir)
    subject.destroy
  end

  it 'should return a revision correctly' do
    resource[:revision] = '123123123'
    subject.expects(:git).with('--git-dir',"#{test_dir}/.git",'rev-parse', 'HEAD').returns('123123123')
    subject.revision.should == '123123123'
  end

  it 'version' do
    resource[:revision] = '123123123'
    subject.expects(:git).with('--git-dir',"#{test_dir}/.git",'rev-parse', 'HEAD').returns('123123123')
    subject.revision.should == '123123123'
  end

end
