# n-bash


**To setup via git mode (requires wget and git):**
```
mode="git" \
&& branch="master" \
&& wget "https://raw.githubusercontent.com/naankari/n-bash/$branch/setup.sh" -O /tmp/nbash-setup.sh \
&& /bin/bash /tmp/nbash-setup.sh "$branch" "$mode" \
&& rm -rf /tmp/nbash-setup.sh
```

**To setup via archive mode (requires wget and unzip):**
```
mode="archive" \
&& branch="master" \
&& wget "https://raw.githubusercontent.com/naankari/n-bash/$branch/setup.sh" -O /tmp/nbash-setup.sh \
&& /bin/bash /tmp/nbash-setup.sh "$branch" "$mode" \
&& rm -rf /tmp/nbash-setup.sh
```

