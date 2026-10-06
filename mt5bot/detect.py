"""Détection automatique du terminal MetaTrader 5 installé (Windows)."""
import glob
import os

EXE = "terminal64.exe"


def _roots(env):
    names = ("PROGRAMFILES", "PROGRAMFILES(X86)", "LOCALAPPDATA", "APPDATA", "USERPROFILE")
    roots = [env[n] for n in names if env.get(n)]
    return roots + [f"{d}:\\" for d in "CDEF"]


def find_terminals(env=None):
    """Retourne les terminal64.exe trouvés, du plus récemment modifié au plus ancien."""
    env = os.environ if env is None else env
    found = set()
    explicit = env.get("MT5_PATH")
    if explicit and os.path.isfile(explicit):
        found.add(os.path.abspath(explicit))
    for root in _roots(env):
        for pattern in (f"*MetaTrader*\\{EXE}", f"*\\*MetaTrader*\\{EXE}", f"*MT5*\\{EXE}"):
            found.update(os.path.abspath(p) for p in glob.glob(os.path.join(root, pattern.replace("\\", os.sep))))
    found = sorted(found, key=os.path.getmtime, reverse=True)
    if explicit and os.path.abspath(explicit) in found:  # le chemin explicite garde la priorité
        found.remove(os.path.abspath(explicit))
        found.insert(0, os.path.abspath(explicit))
    return found


def find_terminal(env=None):
    t = find_terminals(env)
    return t[0] if t else None
