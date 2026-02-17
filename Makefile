# Makefile for Drifting Thoughts iOS Project

# ANSI colors
GREEN=\033[0;32m
RED=\033[0;31m
BLUE=\033[0;34m
YELLOW=\033[1;33m
NC=\033[0m

# Helper to run a command with start/end messages and colored result
# Usage: $(call run,Task Name,actual shell command)
run = \
	@echo "${BLUE}▶ $(1) — started${NC}"; \
	(sh -c "$(2)"); \
	status=$$?; \
	if [ $$status -eq 0 ]; then \
		echo "${GREEN}✔ $(1) — completed successfully${NC}"; \
	else \
		echo "${RED}✖ $(1) — failed (exit $$status)${NC}"; \
		exit $$status; \
	fi

# Build helper with warning/error counting and structured output
# Usage: $(call build_target,Config,Description)
define build_target
	@echo "${BLUE}▶ $(2) — started${NC}"
	@BUILD_LOG=$$(mktemp); \
	set -o pipefail && xcodebuild -scheme DriftingThoughts -configuration $(1) \
		-destination 'generic/platform=iOS Simulator' build 2>&1 | tee $$BUILD_LOG | xcbeautify; \
	status=$$?; \
	warnings=$$(grep "warning:" $$BUILD_LOG 2>/dev/null | grep -v "Metadata extraction skipped" | wc -l | tr -d ' '); \
	errors=$$(grep -c "error:" $$BUILD_LOG 2>/dev/null || echo 0); \
	rm -f $$BUILD_LOG; \
	echo ""; \
	if [ $$status -eq 0 ]; then \
		echo "${GREEN}═══════════════════════════════════════════════════${NC}"; \
		echo "${GREEN}✔ BUILD SUCCEEDED — $(1)${NC}"; \
		if [ $$warnings -gt 0 ]; then \
			echo "${YELLOW}  Warnings: $$warnings${NC}"; \
		else \
			echo "${GREEN}  Warnings: 0${NC}"; \
		fi; \
		echo "${GREEN}═══════════════════════════════════════════════════${NC}"; \
	else \
		echo "${RED}═══════════════════════════════════════════════════${NC}"; \
		echo "${RED}✖ BUILD FAILED — $(1)${NC}"; \
		echo "${RED}  Warnings: $$warnings  Errors: $$errors${NC}"; \
		echo "${RED}═══════════════════════════════════════════════════${NC}"; \
		exit $$status; \
	fi
endef

.PHONY: help open generate generate-sourcekit check-sourcekit build build-release clean clean-all lint format format-lint

help:
	@echo "Drifting Thoughts iOS — Available Commands:"
	@echo ""
	@echo "Build & Clean:"
	@echo "  make open               - Open the Xcode project"
	@echo "  make generate           - Generate Xcode project using XcodeGen"
	@echo "  make generate-sourcekit - Generate SourceKit-LSP configuration"
	@echo "  make check-sourcekit    - Check if SourceKit-LSP configuration is valid"
	@echo "  make build              - Generate Xcode project and build"
	@echo "  make build-release      - Generate Xcode project and build (Release)"
	@echo "  make clean              - Clean build artifacts (keeps .xcodeproj)"
	@echo "  make clean-all          - Full clean including generated project"
	@echo ""
	@echo "Code Quality:"
	@echo "  make lint               - Run SwiftLint on all files (check only)"
	@echo "  make format             - Auto-fix Swift code with SwiftLint --fix"
	@echo "  make format-lint        - Format code then run SwiftLint"
	@echo ""

# ==============================================================================
# LINTING
# ==============================================================================

lint:
	@echo "${BLUE}▶ SwiftLint — started${NC}"
	@LINT_LOG=$$(mktemp); \
	swiftlint lint --config .swiftlint.yml 2>&1 | tee $$LINT_LOG; \
	status=$$?; \
	warnings=$$(grep -cE ": warning:" $$LINT_LOG 2>/dev/null | tr -d '\n' || echo 0); \
	errors=$$(grep -cE ": error:" $$LINT_LOG 2>/dev/null | tr -d '\n' || echo 0); \
	rm -f $$LINT_LOG; \
	echo ""; \
	if [ $$status -eq 0 ]; then \
		echo "${GREEN}═══════════════════════════════════════════════════${NC}"; \
		echo "${GREEN}✔ LINT PASSED${NC}"; \
		if [ "$$warnings" -gt 0 ]; then \
			echo "${YELLOW}  Warnings: $$warnings${NC}"; \
		else \
			echo "${GREEN}  Warnings: 0${NC}"; \
		fi; \
		echo "${GREEN}═══════════════════════════════════════════════════${NC}"; \
	else \
		echo "${RED}═══════════════════════════════════════════════════${NC}"; \
		echo "${RED}✖ LINT FAILED${NC}"; \
		echo "${RED}  Warnings: $$warnings  Errors: $$errors${NC}"; \
		echo "${RED}═══════════════════════════════════════════════════${NC}"; \
		exit $$status; \
	fi

# ==============================================================================
# FORMATTING (using SwiftLint --fix)
# ==============================================================================

format:
	@echo "${BLUE}▶ SwiftLint Fix — started${NC}"
	@BEFORE=$$(mktemp); \
	AFTER=$$(mktemp); \
	git diff > "$$BEFORE" 2>/dev/null || touch "$$BEFORE"; \
	swiftlint lint --fix --config .swiftlint.yml 2>&1; \
	git diff > "$$AFTER" 2>/dev/null || touch "$$AFTER"; \
	formatted=$$(diff "$$BEFORE" "$$AFTER" 2>/dev/null \
		| grep -E '^[<>] diff --git' \
		| sed 's|.* a/||' \
		| sed 's| b/.*||' \
		| sort -u \
		| wc -l \
		| tr -d ' '); \
	rm -f "$$BEFORE" "$$AFTER"; \
	echo ""; \
	echo "${GREEN}═══════════════════════════════════════════════════${NC}"; \
	echo "${GREEN}✔ FORMAT COMPLETED${NC}"; \
	if [ "$$formatted" -gt 0 ]; then \
		echo "${YELLOW}  Files formatted: $$formatted${NC}"; \
	else \
		echo "${GREEN}  No changes needed${NC}"; \
	fi; \
	echo "${GREEN}═══════════════════════════════════════════════════${NC}"

format-lint: format lint
	@echo "${GREEN}✔ Format and lint completed${NC}"

# ==============================================================================
# BUILD
# ==============================================================================

open:
	$(call run,Open Xcode,xed .)

generate:
	$(call run,Check xcodegen installed,command -v xcodegen >/dev/null 2>&1)
	$(call run,Generate Xcode project,xcodegen generate)

generate-sourcekit:
	@if ! command -v xcode-build-server >/dev/null 2>&1; then \
		echo "${RED}✖ xcode-build-server not found. Install with: brew install xcode-build-server${NC}"; \
		exit 1; \
	fi
	@if [ ! -d "DriftingThoughts.xcodeproj" ]; then \
		echo "${YELLOW}▶ Xcode project not found, generating...${NC}"; \
		xcodegen generate; \
	fi
	@echo "${BLUE}▶ Ensuring project is built for indexing...${NC}"
	@xcodebuild -scheme DriftingThoughts -configuration Debug \
		-destination 'generic/platform=iOS Simulator' \
		-quiet build 2>&1 | grep -E "error:" || true
	@mkdir -p .sourcekit-lsp
	@printf '%s\n' \
		'{' \
		'  "swiftPM": {"configuration": "debug"},' \
		'  "compilationDatabase": {"searchPaths": []},' \
		'  "fallbackBuildSystem": {' \
		'    "cCompilerFlags": [],' \
		'    "cxxCompilerFlags": [],' \
		'    "swiftCompilerFlags": []' \
		'  },' \
		'  "defaultWorkspaceType": "buildServer"' \
		'}' > .sourcekit-lsp/config.json
	@echo "${BLUE}▶ Configuring xcode-build-server...${NC}"
	@xcode-build-server config -project DriftingThoughts.xcodeproj -scheme DriftingThoughts
	@echo "${GREEN}✔ SourceKit-LSP configuration generated${NC}"

check-sourcekit:
	@echo "${BLUE}▶ Checking SourceKit-LSP configuration...${NC}"
	@if [ ! -f "buildServer.json" ]; then \
		echo "${RED}✖ buildServer.json not found${NC}"; \
		echo "${YELLOW}  Run: make generate-sourcekit${NC}"; \
		exit 1; \
	fi
	@if [ ! -f ".sourcekit-lsp/config.json" ]; then \
		echo "${RED}✖ .sourcekit-lsp/config.json not found${NC}"; \
		echo "${YELLOW}  Run: make generate-sourcekit${NC}"; \
		exit 1; \
	fi
	@echo "${GREEN}✔ SourceKit-LSP configuration is valid${NC}"

build: generate
	$(call build_target,Debug,Build Debug)

build-release: generate
	$(call build_target,Release,Build Release)

# ==============================================================================
# CLEAN
# ==============================================================================

clean:
	$(call run,Remove build folder,rm -rf build)
	$(call run,Xcode clean,xcodebuild -scheme DriftingThoughts -quiet clean 2>/dev/null || true)
	@echo "${GREEN}✔ Clean completed${NC}"

clean-all: clean
	$(call run,Remove generated project,rm -rf DriftingThoughts.xcodeproj)
	$(call run,Remove generated plists,rm -f Supporting/Info.plist)
	$(call run,Remove SourceKit-LSP config,rm -rf .sourcekit-lsp buildServer.json)
	@echo "${GREEN}✔ Full clean completed. Run 'make generate' to regenerate.${NC}"
