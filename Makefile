build: | clean build-d

# Build with debugging options
build-d:
	export PACKER_LOG=1
	export PACKER_LOG_PATH="packerlog.log"
	packer build --on-error=ask coreos.json

# Build without debugging options
build-n:
	packer build coreos.json

clean:
	rm -rf builds

# This works because we are mounting this directory
# as shared folder under /vagrant
test:
	vagrant ssh -c "source /vagrant/tests/basic_test_suite.sh"
