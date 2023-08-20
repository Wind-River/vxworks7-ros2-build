# `pyyaml`

We can not install `pyyaml` with `pip` as we do for other packages

```bash
pip3 install --ignore-installed --prefix=$(DEPLOY_DIR) pyyaml
``` 

It will install a precompiled extension for Linux and we need one for VxWorks.
Let us build it ourselves. 
