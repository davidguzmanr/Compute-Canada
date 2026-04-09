# Narval
So there seems to be an issue with `datasets` and `Arrow` in Nibi, and quite annoying to solve, see this [thread](https://mila-umontreal.slack.com/archives/C2TL9FRBP/p1764460644840529?thread_ts=1763053658.126349&cid=C2TL9FRBP).

The solution for me is that install `pyarrow` manually, for example (21.0.0):

```
wget https://files.pythonhosted.org/packages/44/28/b6672962639e85dc0ac36f71ab3a8f5f38e01b51343d7aa372a6b56fa3f3/pyarrow-21.0.0-cp310-cp310-manylinux_2_28_x86_64.whl

# 2. Rename it (The Hack)
mv pyarrow-21.0.0-cp310-cp310-manylinux_2_28_x86_64.whl pyarrow-21.0.0-cp310-cp310-linux_x86_64.whl

# 3. Install the renamed file
pip install pyarrow-21.0.0-cp310-cp310-linux_x86_64.whl
```

Then the `pip install --no-index datasets`  should work (not sure whether the --no-index flag could be omitted or not).