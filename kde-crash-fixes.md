### 1

Figure out what they call the kde session.
Using top or pstree you will probably see it.
Then kill that process from the console with pkill (or just from top using the pid).
Something like:

```bash
sudo pkill kde-session
```
That would likely just cause it to reload and give you a new login screen.
I'm not on KDE or arch at the moment though, so not sure the exact command.

### 2

In KDE > 5.10 use:

```bash
kquitapp5 plasmashell
kstart5 plasmashell
```

Sometimes plasmashell is not responding so kquitapp5 fails after a timeout
<br>and you have to get back to killall.
So in a nutshell, I would do :

```bash
# For KDE > 5.10
kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell
```

You can skip the kquitapp5 plasmashell || part
<br>if you don't want to be stuck in the timeout when plasmashell is not responding.

### 3

This reloads KDE's compositor:

```bash
kwin --replace
# or
plasmashell --replace &
```

### 4

With sleep:

```bash
killall plasmashell ; sleep 3 ; kwin --replace ; sleep 5 ; kstart plasmashell
```

### 5

Super-duper

```bash
killall plasmashell desktop.so file.so ; sleep 5 ; kwin --replace ; sleep 5 ; kstart plasmashell
```
