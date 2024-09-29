huggingface:
	BUILDKIT_PROGRESS=plain docker compose build upload-hugging-face
	BUILDKIT_PROGRESS=plain docker compose up upload-hugging-face

unit-tests:
	BUILDKIT_PROGRESS=plain docker compose build mina-local-network # build base image
	BUILDKIT_PROGRESS=plain TESTS="/app/dist/node/lib/util/base58.unit-test.js" docker compose build unit-tests
	BUILDKIT_PROGRESS=plain TESTS="/app/dist/node/lib/util/base58.unit-test.js" docker compose up unit-tests

unit-tests-local:
	BUILDKIT_PROGRESS=plain TESTS="/app/dist/node/lib/util/base58.unit-test.js" docker compose build unit-tests-local 
	BUILDKIT_PROGRESS=plain TESTS="/app/dist/node/lib/util/base58.unit-test.js" docker compose up unit-tests-local

test:
	docker compose build mina-local-network
	docker compose up mina-local-network
