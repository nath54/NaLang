"""
Petit script pour trouver les erreurs dans les cours générés.
La principale erreur que j'ai trouvée quand je regardais les cours, c'était des erreurs de tags.
Des fois des tags étaient ouvertes, mais n'étaient pas refermées, ou alors, pour la refermer, le modèle en réouvrait une autre, ou bien alors, il y avait aussi des erreurs de tags de type font_size ou color, avec des mauvais arguments, ou une mauvaise syntaxe (un / au lieu du = par ex).
Le principe de ce script sera donc de détecter tout cela.

Auteur: Nathan Cerisara
"""

from typing import Optional, IO, List
import json
import os
import re


# source : https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html#reference

# dict[tag_name: argument_type] | argument types : 0 = no arg, 1 = integer arg (>0 & < INTEGER_ARG_LIMIT), 2 = color, 3 = texte lambda, 4 = iso lang code
TAG_TYPES: dict[str, int] = {
    "b": 0,
    "i": 0,
    "u": 0,
    "s": 0,
    "code": 0,
    "p": 0,
    "center": 0,
    "left": 0,
    "right": 0,
    "fill": 0,
    "indent": 0,
    "url": 4,
    "hint": 4,
    "font_size": 1,
    "color": 2,
    "lang": 5,
    "bgcolor": 2,
    "fgcolor": 2,
    "outline_size": 1,
    "outline_color": 2,
    "table": 1,
    "cell": 0,
    "ul": 0,
    "ol": 0
}

CHIFFRES: str = "0123456789"

INTEGER_ARG_LIMIT: int = 100

COLOR_NAMES: set[str] = {"black", "white", "grey", "purple", "blue", "red", "orange", "yellow", "green", "cyan", "magenta"}

HEX_CHARS: str = "0123456789abcdef"

with open("./language-codes.json", "r", encoding="utf-8") as f:
    ISO_LANGS: dict[str, str] = json.load(f)

# Motif regex pour capturer les tags BBCode
OPENING_TAG_REGEX_PATTERN = r'\[([a-zA-Z0-9_]+)(?:=([^\]]+))?\]'
CLOSING_TAG_REGEX_PATTERN = r'\[/([a-zA-Z0-9_]+)\]'

#
def is_integer(txt: str) -> bool:
    for l in txt:
        if not l in CHIFFRES:
            return False
    return True


class Error:
    def __init__(self, msg: str) -> None:
        self.msg: str = msg

    def __str__(self):
        pass


#
class TagError:
    def __init__(self, msg: str, tag: Tag) -> None:
        super.__init__(self, msg)
        self.tag: Tag = tag


#
class Tag:
    #
    def __init__(self, tag_type: str, tag_line_opened: int, tag_cursor_opened: int, tag_argument: Optional[str] = None) -> None:
        self.tag_type: str = tag_type
        self.tag_line_opened: int = tag_line_opened
        self.tag_cursor_opened: int = tag_cursor_opened
        self.tag_argument: Optional[str] = tag_argument

    #
    def __str__(self) -> str:
        if self.tag_argument is None:
            return f"Tag(type={self.tag_type}, l={self.tag_line_opened}, c={self.tag_cursor_opened})"
        else:
            return f"Tag(type={self.tag_type}, l={self.tag_line_opened}, c={self.tag_cursor_opened}), arg={self.tag_argument}"

    #
    def verify_tag(self) -> Optional[Error]:
        # 0 = no arg
        if TAG_TYPES[self.tag_type] == 0:
            if self.tag_argument is not None:
                return Error(self, f"Cette tag ne devrait pas avoir d'arguments, mais elle a pourtant reçu \"{self.tag_argument}\" comme argument")
        # 1 = integer arg (>0 & < INTEGER_ARG_LIMIT)
        elif TAG_TYPES[self.tag_type] == 1:
            if self.tag_argument is not None:
                if not is_integer(self.tag_argument):
                    return Error(self, f"L'argument de cette tag doit être un entier strictement positif! Ce n'est pas le cas: \"{self.tag_argument}\"")
                elif int(self.tag_argument) == 0 or int(self.tag_argument) > INTEGER_ARG_LIMIT:
                    return Error(self, f"L'argument de cette tag doit être un entier strictement positif et strictement inférieur à {INTEGER_ARG_LIMIT}! Ce n'est pas le cas: \"{self.tag_argument}\"")
        # 2 = color
        elif TAG_TYPES[self.tag_type] == 2:
            if self.tag_argument is not None:
                if not self.tag_argument in COLOR_NAMES:
                    if len(self.tag_argument) != 7 or self.tag_argument[0] != "#":
                        return Error(self, f"L'argument de cette tag doit être soit un nom de couleur connue en anglais, ou alors un code couleur hexadécimal de la forme #rrggbb ! Ce n'est pas le cas: \"{self.tag_argument}\"")
                    for i in range(1, 7):
                        if self.tag_argument[i] not in HEX_CHARS:
                            return Error(self, f"Mauvais code couleur hexadécimal rgb : \"{self.tag_argument}\" !")
        # 3 = texte lambda
        elif TAG_TYPES[self.tag_type] == 3:
            if self.tag_argument is not None:
                if len(self.tag_argument) == 0:
                    return Error(self, f"L'argument de cette tag doit être texte quelconque non vide ! Ce n'est pas le cas: \"{self.tag_argument}\"")
        # 4 = iso lang code
        elif TAG_TYPES[self.tag_type] == 4:
            if self.tag_argument is not None:
                if not self.tag_argument in ISO_LANGS:
                    return Error(self, f"L'argument de cette tag doit être code de langue définie dans la norme iso ! Ce n'est pas le cas: \"{self.tag_argument}\"")
        # No error detected
        return None


#
class ErrorDetection:
    #
    def __init__(self, file_path: str) -> None:
        #
        self.file_path: str = file_path
        #
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Erreur: le fichier {file_path} n'existe pas!")

        #
        self.file_lines: list[str] = []
        with open(file_path, "r", encoding="utf-8") as f:
            self.file_lines = f.read().split("\n")
        #
        self.current_line: int = 0
        self.cursor: int = 0
        #
        self.opened_tags: list[Tag] = []
        #
        self.tag_opened_counts: dict[str, int] = {}
        self.tag_closed_counts: dict[str, int] = {}

    #
    def detect(self) -> list[Error]:
        #
        errors: list[Error] = []
        #
        line_number: int
        for line_number in range(len(self.file_lines)):
            # on récupère la ligne
            line: str = self.file_lines[line_number]

            ## OPENING TAGS

            # Utilisation de re.finditer pour obtenir les positions et les correspondances
            matches = re.finditer(OPENING_TAG_REGEX_PATTERN, line)

            # Affichage des correspondances trouvées avec leurs positions
            for match in matches:
                tag_name = match.group(1)
                tag_argument = match.group(2)
                start_pos = match.start()
                #
                if tag_name in TAG_TYPES:
                    #
                    tag: Tag = Tag(tag_name, line_number, start_pos, tag_argument)
                    #
                    err: Optional[Error] = tag.verify_tag()
                    if err is not None:
                        errors.append(err)
                    # On ajoute le tag à la liste des tags actifs
                    self.opened_tags.append(tag)
                    #
                    if not tag_name in self.tag_opened_counts:
                        self.tag_opened_counts[tag_name] = 0
                    #
                    self.tag_opened_counts[tag_name] += 1

            ## CLOSING TAGS

            # Utilisation de re.finditer pour obtenir les positions et les correspondances
            closing_matches = re.finditer(CLOSING_TAG_REGEX_PATTERN, line)

            # Affichage des correspondances trouvées avec leurs positions
            for match in closing_matches:
                tag_name = match.group(1)
                start_pos = match.start()
                #
                if len(self.opened_tags) == 0:
                    errors.append(Error(f"Erreur: Essai de fermer le tag [{tag_name}] (ligne {line_number}, curseur: {start_pos}), mais il n'y a pas de tags à fermer!!!"))
                elif self.opened_tags[-1].tag_type != tag_name:
                    errors.append(Error(f"Erreur: Essai de fermer le tag [{tag_name}] (ligne {line_number}, curseur: {start_pos}), mais le dernier tag ouvert est de type {self.opened_tags[-1].tag_type}!!!"))
                else:
                    self.opened_tags.pop(-1)

                #
                if not tag_name in self.tag_closed_counts:
                    self.tag_closed_counts[tag_name] = 0
                #
                self.tag_closed_counts[tag_name] += 1

        return errors

    #
    def print_errors(self, error_list: list[Error]) -> None:
        pass
        # TODO




if __name__ == "__main__":
    pass
    # TODO

