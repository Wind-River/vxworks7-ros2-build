# Makefile - build pipeline for VxWorks 7 and ROS 2
#
# Copyright (c) 2019 Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Modification history
# --------------------
# 16apr19,rcw  created

LOCAL_DIR=$(dirname $(readlink -f $0))
STAMP_DIR=$(CURDIR)/.stamp
SCRIPTS_DIR=$(CURDIR)/scripts

VPATH=$(STAMP_DIR)
MAKE_STAMP=touch $(STAMP_DIR)/$@

SUBPRJS=vsb prj bootloader vip
TARGETS=$(addsuffix .install,$(SUBPRJS))

define run_script
  if [ -f $(SCRIPTS_DIR)/$(subst .,-,$1).sh ]; then \
    echo "## RUN: $(SCRIPTS_DIR)/$(subst .,-,$1).sh"; \
    $(SCRIPTS_DIR)/$(subst .,-,$1).sh; \
    if [ $$? -ne 0 ]; then \
      echo "## ERROR: $(SCRIPTS_DIR)/$(subst .,-,$1).sh"; \
      exit 1; \
    else \
      echo "## SUCCESS: $(SCRIPTS_DIR)/$(subst .,-,$1).sh"; \
    fi; \
  fi;
endef

all: $(STAMP_DIR) $(TARGETS)

clean:
	@rm -rf $(STAMP_DIR)

$(STAMP_DIR):
	@mkdir -p $(STAMP_DIR)

%.create:
	@$(call run_script,$@)
	@$(MAKE_STAMP)

%.download: %.create
	@$(call run_script,$@)
	@$(MAKE_STAMP)

%.patch: %.download
	@$(call run_script,$@)
	@$(MAKE_STAMP)

%.configure: %.patch
	@$(call run_script,$@)
	@$(MAKE_STAMP)

%.build: %.configure
	@$(call run_script,$@)
	@$(MAKE_STAMP)

%.install: %.build
	@$(call run_script,$@)
	@$(MAKE_STAMP)
