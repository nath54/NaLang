"""
Petit script pour trouver les erreurs dans les cours générés.
La principale erreur que j'ai trouvée quand je regardais les cours, c'était des erreurs de tags.
Des fois des tags étaient ouvertes, mais n'étaient pas refermées, ou alors, pour la refermer, le modèle en réouvrait une autre, ou bien alors, il y avait aussi des erreurs de tags de type font_size ou color, avec des mauvais arguments, ou une mauvaise syntaxe (un / au lieu du = par ex).
Le principe de ce script sera donc de détecter tout cela.

Auteur: Nathan Cerisara
"""

from __future__ import annotations
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

COLOR_NAMES: set[str] = {"black", "white", "grey", "purple", "blue", "red", "orange", "yellow", "green", "cyan", "magenta", "dark green", "dark red", "dark blue"}

HEX_CHARS: str = "0123456789abcdef"

with open("./language-codes.json", "r", encoding="utf-8") as f:
    ISO_LANGS: dict[str, str] = json.load(f)

# Motif regex pour capturer les tags BBCode
OPENING_TAG_REGEX_PATTERN = r'\[([a-zA-Z0-9_]+)(?:=([^\]]+))?\]'
CLOSING_TAG_REGEX_PATTERN = r'\[/([a-zA-Z0-9_]+)\]'

# Variable globale pour savoir si on a détecté des erreurs ou non
error_detected: bool = False


#
def is_integer(txt: str) -> bool:
    """
    Teste si un texte peut représenter un entier valide ou non.

    Args:
        txt (str): texte à tester

    Returns:
        bool: Si le texte donné en entrée peut représenter un entier valide ou non.
    """

    for l in txt:
        if not l in CHIFFRES:
            return False
    return True


class Error:
    """
    Classe qui représente les erreurs
    """

    #
    def __init__(self, msg: str) -> None:
        self.msg: str = msg

    #
    def __str__(self) -> str:
        """
        Affiche l'erreur

        Returns:
            str: texte de l'erreur
        """

        return f"\033[91m{self.msg}\033[m"


#
class TagError(Error):
    """
    Classe qui représente les erreurs spécifiques aux balises
    """

    #
    def __init__(self, msg: str, tag: Tag) -> None:
        super().__init__(msg)
        self.tag: Tag = tag

    #
    def __str__(self) -> str:
        """
        Affiche l'erreur

        Returns:
            str: texte de l'erreur
        """

        return f"\033[91mErreur de tag à la ligne {self.tag.tag_line_opened + 1} colonne {self.tag.tag_cursor_opened + 1} sur le tag {self.tag} : \n  -> {self.msg}\033[m"


#
class Tag:
    """
    Classe qui représente les tags bbcode
    """

    #
    def __init__(self, tag_type: str, tag_line_opened: int, tag_cursor_opened: int, tag_argument: Optional[str] = None) -> None:
        self.tag_type: str = tag_type
        self.tag_line_opened: int = tag_line_opened
        self.tag_cursor_opened: int = tag_cursor_opened
        self.tag_argument: Optional[str] = tag_argument

    #
    def __str__(self) -> str:
        """
        Affiche le tag

        Returns:
            str: Texte d'affichage
        """

        if self.tag_argument is None:
            return f"\033[34mTag(type={self.tag_type}, l={self.tag_line_opened + 1}, c={self.tag_cursor_opened + 1})\033[m"
        else:
            return f"\033[34mTag(type={self.tag_type}, l={self.tag_line_opened + 1}, c={self.tag_cursor_opened + 1}), arg={self.tag_argument}\033[m"

    #
    def verify_tag(self) -> Optional[Error]:
        """
        Vérifie si les arguments du tag sont corrects.

        Returns:
            Optional[Error]: S'il y a une erreur, on la renvoie.
        """

        # 0 = no arg
        if TAG_TYPES[self.tag_type] == 0:
            if self.tag_argument is not None:
                return TagError(f"Cette tag ne devrait pas avoir d'arguments, mais elle a pourtant reçu \"{self.tag_argument}\" comme argument", self)
        # 1 = integer arg (>0 & < INTEGER_ARG_LIMIT)
        elif TAG_TYPES[self.tag_type] == 1:
            if self.tag_argument is not None:
                if not is_integer(self.tag_argument):
                    return TagError(f"L'argument de cette tag doit être un entier strictement positif! Ce n'est pas le cas: \"{self.tag_argument}\"", self)
                elif int(self.tag_argument) == 0 or int(self.tag_argument) > INTEGER_ARG_LIMIT:
                    return TagError(f"L'argument de cette tag doit être un entier strictement positif et strictement inférieur à {INTEGER_ARG_LIMIT}! Ce n'est pas le cas: \"{self.tag_argument}\"", self)
        # 2 = color
        elif TAG_TYPES[self.tag_type] == 2:
            if self.tag_argument is not None:
                if not self.tag_argument in COLOR_NAMES:
                    if len(self.tag_argument) != 7 or self.tag_argument[0] != "#":
                        return TagError(f"L'argument de cette tag doit être soit un nom de couleur connue en anglais, ou alors un code couleur hexadécimal de la forme #rrggbb ! Ce n'est pas le cas: \"{self.tag_argument}\"", self)
                    for i in range(1, 7):
                        if self.tag_argument[i].lower() not in HEX_CHARS:
                            return TagError(f"Mauvais code couleur hexadécimal rgb : \"{self.tag_argument}\" !", self)
        # 3 = texte lambda
        elif TAG_TYPES[self.tag_type] == 3:
            if self.tag_argument is not None:
                if len(self.tag_argument) == 0:
                    return TagError(f"L'argument de cette tag doit être texte quelconque non vide ! Ce n'est pas le cas: \"{self.tag_argument}\"", self)
        # 4 = iso lang code
        elif TAG_TYPES[self.tag_type] == 4:
            if self.tag_argument is not None:
                if not self.tag_argument in ISO_LANGS:
                    return TagError(f"L'argument de cette tag doit être code de langue définie dans la norme iso ! Ce n'est pas le cas: \"{self.tag_argument}\"", self)
        # No error detected
        return None


#
class ErrorDetection:
    """
    Classe principale qui va détecter les erreurs de balises bbcode sur un fichier.
    """

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
        self.error_list: List[Error] = []

    #
    def detect(self) -> bool:
        """
        Fonction de détection des tags bbcode d'un fichier. On s'occupe d'abord des tags ouvrants et des tags fermants, puis des tags non fermés.
        
        Return
            (bool): S'il y a une erreur qui a été détectée ou non.
        """

        #
        line_number: int
        for line_number in range(len(self.file_lines)):
            # on récupère la ligne
            line: str = self.file_lines[line_number]

            # Utilisation de re.finditer pour obtenir les positions et les correspondances
            matches = re.finditer(OPENING_TAG_REGEX_PATTERN+"|"+CLOSING_TAG_REGEX_PATTERN, line)

            # Affichage des correspondances trouvées avec leurs positions
            for match in matches:
                #
                tag_name: str = match.group(1) if match.group(1) is not None else match.group(3)
                tag_argument: Optional[str] = match.group(2)
                start_pos = match.start()

                # print(f"line : \"{line}\"\n  - line[{start_pos + 1}] = '{line[start_pos + 1]}'")
                if tag_name in TAG_TYPES:

                    if line[start_pos+1] != "/":  ## OPENING TAG
                        # print(f"\033[33mOpening tag detected: [{tag_name}] (line: {line_number}, cursor: {start_pos})\033[m")
                        
                            #
                            tag: Tag = Tag(tag_name, line_number, start_pos, tag_argument)
                            #
                            err: Optional[Error] = tag.verify_tag()
                            if err is not None:
                                self.error_list.append(err)
                            # On ajoute le tag à la liste des tags actifs
                            self.opened_tags.append(tag)
                            #
                            if not tag_name in self.tag_opened_counts:
                                self.tag_opened_counts[tag_name] = 0
                            #
                            self.tag_opened_counts[tag_name] += 1

                    else: ## CLOSING TAG
                        # print(f"\033[33mClosing tag detected: [{tag_name}] (line: {line_number}, cursor: {start_pos})\033[m")
                        #
                        if len(self.opened_tags) == 0:
                            self.error_list.append(Error(f"Erreur: Essai de fermer le tag [{tag_name}] (ligne {line_number + 1}, colonne: {start_pos + 1}), mais il n'y a pas de tags à fermer!!!"))
                        elif self.opened_tags[-1].tag_type != tag_name:
                            self.error_list.append(Error(f"Erreur: Essai de fermer le tag [{tag_name}] (ligne {line_number + 1}, colonne: {start_pos + 1}), mais le dernier tag ouvert est de type {self.opened_tags[-1].tag_type}!!!"))
                        else:
                            self.opened_tags.pop(-1)

                        #
                        if not tag_name in self.tag_closed_counts:
                            self.tag_closed_counts[tag_name] = 0
                        #
                        self.tag_closed_counts[tag_name] += 1

        #
        for tag in self.opened_tags:
            self.error_list.append(TagError(f"Erreur: tag non fermé : {tag.tag_type}", tag))

        #
        return len(self.error_list) != 0

    #
    def print_errors(self) -> None:
        """
        Affiche les erreurs détectées
        """

        print(f"\n\n\033[35mVérification du fichier {self.file_path}:\033[m\n")

        #
        if len(self.error_list) == 0:
            print(f"\033[92mPas d'erreurs détectées pour le fichier {self.file_path}\033[m")

        #
        for error in self.error_list:
            print(error)

        #
        print(f"\n\nBilan des balises.\n\n\033[1mBalises ouvrantes - Balises fermantes:\033[m")
        #
        for tag_type in list(set(list(self.tag_opened_counts.keys()) + list(self.tag_closed_counts.keys()))):
            nb_opened: str = str(self.tag_opened_counts.get(tag_type, "/"))
            nb_closed: str = str(self.tag_closed_counts.get(tag_type, "/"))
            if nb_opened != nb_closed: print("\033[31;1m", end="")
            print(f" * {tag_type} : {nb_opened} - {nb_closed}")
            if nb_opened != nb_closed: print("\033[m", end="")
        #
        print("")


#
def exploration_and_detection(path: str) -> None:
    """
    Fonction récursive qui va explorer les sous dossiers et qui va vérifier les erreurs de chaque fichier qu'il rencontre.

    Args:
        path (str): Chemin à explorer
    """

    # On renvoie une erreur si problèmes de chemin, ca veut dire qu'il y a un gros problème dans ce code
    if not os.path.exists(path):
        raise FileNotFoundError(f"Erreur, ce chemin n'existe pas : {path}")

    #
    for p in os.listdir(path):
        #
        if os.path.isfile(path+p) and p != "prompt_to_gen.txt":
            #
            err_detect: ErrorDetection = ErrorDetection(path+p)
            if err_detect.detect():
                #
                error_detected = True
                #
                err_detect.print_errors()
                #
                input("\n[Press Enter For Next File]")
        #
        elif os.path.isdir(path+p):
            #
            exploration_and_detection(path+p+"/")



#
if __name__ == "__main__":
    #
    exploration_and_detection("./cours/")
    #
    if not error_detected:
        print("\n\033[92mPas d'erreurs détectées. Tout est bon !\033[m\n")

