shared_context 'common stuff' do
  let(:log) { Logger.new(STDOUT).tap { |l| l.level = Logger::INFO } }
  let(:node) do
    node = Chef::Node.new
    # node.automatic['platform'] = 'ubuntu'
    # node.automatic['platform_version'] = '12.04'
    node.normal['galoshes']['aws_access_key_id'] = 'fake_access_key'
    node.normal['galoshes']['aws_secret_access_key'] = 'fake_secret_key'
    node
  end
  let(:events) { Chef::EventDispatch::Dispatcher.new }
  let(:run_context) { Chef::RunContext.new(node, {}, events) }
end
