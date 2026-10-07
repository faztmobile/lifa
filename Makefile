.PHONY: api trace
api:   ## Lint and bundle all OpenAPI specs
	npm run api:lint && npm run api:bundle
trace: api  ## Regenerate the FR traceability matrix
	python3 -I tools/traceability.py --check
