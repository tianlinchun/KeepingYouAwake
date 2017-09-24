SCHEME = KeepingYouAwake
PROJECT = KeepingYouAwake.xcodeproj
VERSION = 1.5.0pre

OUTPUT_DIR = $(shell pwd)/dist

clean:
	rm -rf build
	rm -rf Carthage
	rm -rf $(OUTPUT_DIR)

Carthage:
	carthage bootstrap --use-ssh --platform macOS

$(OUTPUT_DIR)/$(SCHEME).app: Carthage
	fastlane gym \
	--project $(PROJECT) \
	--scheme $(SCHEME) \
	--output_directory $(OUTPUT_DIR) \
	--buildlog_path $(OUTPUT_DIR) \
	--archive_path $(OUTPUT_DIR)/$(SCHEME).xcarchive

$(OUTPUT_DIR)/$(SCHEME)-$(VERSION).zip: $(OUTPUT_DIR)/$(SCHEME).app
	@echo "Exporting $(OUTPUT_DIR)/$(SCHEME)-$(VERSION).zip..."
	@ditto -c -k --sequesterRsrc --keepParent $(OUTPUT_DIR)/$(SCHEME).app $(OUTPUT_DIR)/$(SCHEME)-$(VERSION).zip

dist: $(OUTPUT_DIR)/$(SCHEME)-$(VERSION).zip
	@echo "Verifying code signing identity..."
	@spctl -a -vv $(OUTPUT_DIR)/$(SCHEME).app

clangformat:
	$(info Reformatting source files with clang-format...)
	clang-format -style=file -i $(shell pwd)/**/*.{h,m}

.PHONY: clean dist clang-format
