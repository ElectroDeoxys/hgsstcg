import glob
import re

patterns = [
    r"[a-z_]+(?:.+,){0,6} +([a-zA-Z0-9_]{3,})",
    r"dw ([a-zA-Z0-9_]{3,})",
    r"call ([a-zA-Z0-9_]{3,})",
    r"call n?z, ([a-zA-Z0-9_]{3,})",
    r"call n?c, ([a-zA-Z0-9_]{3,})",
    r"jp ([a-zA-Z0-9_]{3,})",
    r"jp n?z, ([a-zA-Z0-9_]{3,})",
    r"jp n?c, ([a-zA-Z0-9_]{3,})",
    r"jr ([a-zA-Z0-9_]{3,})",
    r"jr n?z, ([a-zA-Z0-9_]{3,})",
    r"jr n?c, ([a-zA-Z0-9_]{3,})",
    r"ldh? \[?[abcdehl]{1,2}\]?, \[?([a-zA-Z0-9_]{3,})\]?",
    r"ldh? \[?[abcdehl]{1,2}\]?, (?:LOW|HIGH)\(([a-zA-Z0-9_]{3,})\)",
    r"ldh? \[([a-zA-Z0-9_]{3,})\], a",
]

def main():
    symbols = {}
    with open("hgsstcg.map", "r") as file:
        body = file.read()
        for match in re.finditer(r"\$[a-f0-9]{4} = ([^\.]+?)\n", body):
            symbols[match[1]] = False

    for asm_file in glob.glob("**/*.asm", recursive=True):
        with open(asm_file, "r") as file:
            body = file.read()
            for pattern in patterns:
                for match in re.finditer(pattern, body):
                    symbols[match[1]] = True

    for sym, found in symbols.items():
        if found:
            continue
        print(f"{sym}")

if __name__ == "__main__":
    main()
