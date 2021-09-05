# BRANCH = $(git rev-parse --abbrev-ref HEAD)

.PHONY: all clean set_artifacts_directory package
# Perform full deployment
full-update: clean set_artifacts_directory package update
packagename = "src"



# Clean out artifacts
clean: 
	@( \
		rm -rf ./artifact/
	)

set_artifacts_directory:
	@mkdir -p ./artifact/source; \



package: set_artifacts_directory
	@echo "Creating Artifact"
	@( \
		cp -R ./src/* ./artifact/source; \
		pushd ./artifact/source > /dev/null 2>&1; \
		docker run -v ${PWD}/artifact:/app -w /app/source python:3.8-slim-buster pip \
			-v install -q -r requirements.txt; \
		zip -r9 ../artifact.zip . > /dev/null 2>&1; \
		popd > /dev/null 2>&1; \
		rm -rf ./artifact/source; \
    	)

update:
	@echo "Updating Lambda..."
	@aws lambda update-function-code --function-name "$(packagename)-lambda" --zip-file fileb://artifact/artifact.zip --region us-east-1


destroy:
	@echo "Destroying Lambda..."
	@( \
		@aws lambda update-function-code --function-name "$(packagename)-lambda" --zip-file fileb://artifact/artifact.zip --region us-east; \
	)
