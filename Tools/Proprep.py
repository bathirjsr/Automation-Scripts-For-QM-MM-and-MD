#!/usr/bin/env python3
from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from dataclasses import dataclass
from typing import Dict, Iterable, List, Optional, Set, Tuple

from Bio.PDB import PDBParser, PDBIO, Select
from Bio.PDB.Structure import Structure
from Bio.PDB.Residue import Residue
from Bio.PDB.Atom import Atom


# --- Definitions (edit as needed) ---

AA_3LETTER: Set[str] = {
    "ALA","ARG","ASN","ASP","CYS","GLN","GLU","GLY","HIS","ILE",
    "LEU","LYS","MET","PHE","PRO","SER","THR","TRP","TYR","VAL",
    # Common protonation/variants often seen
    "HID","HIE","HIP","CYX","CYM","ASH","GLH","LYN","ARN","TYM","HSD","HSE","HSP",
    # Selenomethionine (common in X-ray)
    "MSE",
}

NA_3LETTER: Set[str] = {
    "A","C","G","U","I",      # RNA
    "DA","DC","DG","DT","DI", # DNA
}

WATER_NAMES: Set[str] = {"HOH", "WAT", "H2O", "DOD"}

ION_NAMES: Set[str] = {
    "NA","K","CL","MG","CA","ZN","MN","FE","CO","NI","CU","CD","SR","CS","I",
    "BR","F","LI","AL","HG","PB","BA","RB","CR","SE",
}

# A practical starting set of cofactors. Add/remove freely.
COFACTOR_NAMES: Set[str] = {
    "HEM","HEA","HEC","HEB",
    "FAD","FMN",
    "NAD","NADH","NADP","NAP",
    "SAM","SAH",
    "ATP","ADP","AMP",
    "GTP","GDP","GMP",
    "COA","ACO",
    "PLP",
    "TPP",
    "UDP","UMP","UTP",
    "FES","SF4","FS4",  # iron-sulfur clusters appear as different codes sometimes
}

# Hydrogens: PDB atom element is best, but not always present. We handle both.
def is_hydrogen(atom: Atom) -> bool:
    el = (atom.element or "").strip().upper()
    if el == "H":
        return True
    # fallback: atom name often starts with H for hydrogens
    nm = (atom.get_name() or "").strip().upper()
    return nm.startswith("H")


@dataclass(frozen=True)
class ResidKey:
    chain: str
    hetflag: str
    resseq: int
    icode: str
    resname: str


def residue_key(res: Residue, chain_id: str) -> ResidKey:
    hetflag, resseq, icode = res.get_id()
    return ResidKey(
        chain=chain_id,
        hetflag=str(hetflag),
        resseq=int(resseq),
        icode=str(icode).strip() if icode else "",
        resname=res.get_resname().strip().upper(),
    )


def classify_resname(resname: str) -> str:
    rn = resname.upper()
    if rn in WATER_NAMES:
        return "water"
    if rn in AA_3LETTER:
        return "protein"
    if rn in NA_3LETTER:
        return "nucleic_acid"
    if rn in ION_NAMES:
        return "ion"
    if rn in COFACTOR_NAMES:
        return "cofactor"
    # Anything else that is not standard polymer residue usually comes as HETATM ligand
    return "organic_or_other_ligand"


# --- Cleaning logic ---

def choose_altloc_best(atoms: Iterable[Atom]) -> List[Atom]:
    """
    For atoms with same name but different altlocs, keep:
      - blank altloc if present, else
      - highest occupancy, else
      - first encountered
    """
    by_name: Dict[str, List[Atom]] = defaultdict(list)
    for a in atoms:
        by_name[a.get_name()].append(a)

    chosen: List[Atom] = []
    for name, alts in by_name.items():
        # Prefer altloc blank if present
        blank = [a for a in alts if (a.get_altloc() or "").strip() in ("", " ")]
        if blank:
            chosen.append(blank[0])
            continue
        # else choose highest occupancy
        def occ(a: Atom) -> float:
            o = a.get_occupancy()
            return float(o) if o is not None else -1.0
        alts_sorted = sorted(alts, key=occ, reverse=True)
        chosen.append(alts_sorted[0])
    return chosen


def clean_structure(
    structure: Structure,
    remove_waters: bool,
    remove_ions: bool,
    remove_h: bool,
    keep_only_first_model: bool,
) -> Structure:
    """
    Mutates the structure in-place (BioPython objects are mutable).
    Removes unwanted residues/atoms and resolves altlocs.
    """
    # Optionally drop extra models by just processing model 0
    models = list(structure.get_models())
    if keep_only_first_model and len(models) > 1:
        # Remove all models except first
        first = models[0]
        for m in models[1:]:
            structure.detach_child(m.id)
        models = [first]

    for model in models:
        for chain in list(model.get_chains()):
            for res in list(chain.get_residues()):
                resname = res.get_resname().strip().upper()

                if remove_waters and resname in WATER_NAMES:
                    chain.detach_child(res.id)
                    continue
                if remove_ions and resname in ION_NAMES:
                    chain.detach_child(res.id)
                    continue

                # Resolve altlocs + optionally remove hydrogens
                atoms = list(res.get_atoms())
                kept = choose_altloc_best(atoms)

                # Remove atoms not in kept
                keep_ids = {a.id for a in kept}  # Atom.id is atom name in Biopython
                for atom in list(res.get_atoms()):
                    # if atom name not kept, delete
                    if atom.id not in keep_ids:
                        res.detach_child(atom.id)
                        continue
                    if remove_h and is_hydrogen(atom):
                        res.detach_child(atom.id)

                # If residue becomes empty, drop it
                if len(list(res.get_atoms())) == 0:
                    chain.detach_child(res.id)

            # If chain becomes empty, drop it
            if len(list(chain.get_residues())) == 0:
                model.detach_child(chain.id)

    return structure


class CleanSelect(Select):
    """Used by PDBIO to write everything left in the structure."""
    def accept_atom(self, atom: Atom) -> int:
        return 1


def audit_structure(structure: Structure) -> Dict[str, object]:
    """
    Returns counts by class and by residue name, plus instance counts.
    """
    counts_by_class = Counter()
    counts_by_resname = Counter()
    instances_by_resname = Counter()
    instances_by_class = Counter()

    for model in structure:
        for chain in model:
            for res in chain:
                key = residue_key(res, chain.id)
                rn = key.resname
                cls = classify_resname(rn)

                counts_by_class[cls] += 1
                counts_by_resname[rn] += 1

                # Instance count: unique (chain, resseq, icode, resname, hetflag)
                inst = (key.chain, key.hetflag, key.resseq, key.icode, key.resname)
                instances_by_resname[(rn, inst)] += 1  # for uniqueness tracking
                # We'll compress below

    # Compress unique instances
    unique_instances_resname = Counter()
    unique_instances_class = Counter()
    seen_instances: Set[Tuple[str, str, int, str, str]] = set()

    for model in structure:
        for chain in model:
            for res in chain:
                key = residue_key(res, chain.id)
                inst = (key.chain, key.hetflag, key.resseq, key.icode, key.resname)
                if inst in seen_instances:
                    continue
                seen_instances.add(inst)
                rn = key.resname
                cls = classify_resname(rn)
                unique_instances_resname[rn] += 1
                unique_instances_class[cls] += 1

    return {
        "counts_by_class_residues": counts_by_class,         # number of residues
        "counts_by_resname_residues": counts_by_resname,     # number of residues by name
        "counts_by_class_instances": unique_instances_class, # unique molecules by residue id
        "counts_by_resname_instances": unique_instances_resname,
    }


def print_report(report: Dict[str, object]) -> None:
    c_class = report["counts_by_class_residues"]
    c_res = report["counts_by_resname_residues"]
    i_class = report["counts_by_class_instances"]
    i_res = report["counts_by_resname_instances"]

    def print_counter(title: str, ctr: Counter, top: Optional[int] = None) -> None:
        print(f"\n{title}")
        print("-" * len(title))
        items = ctr.most_common() if top is None else ctr.most_common(top)
        for k, v in items:
            print(f"{k:24s} {v}")

    print_counter("Residue counts by class", c_class)
    print_counter("Unique instance counts by class", i_class)

    print_counter("Residue counts by residue name", c_res)
    print_counter("Unique instance counts by residue name", i_res)


def main():
    ap = argparse.ArgumentParser(
        description="Clean a PDB and report residues/ligands/cofactors with counts."
    )
    ap.add_argument("pdb_in", help="Input PDB file path")
    ap.add_argument("-o", "--out", default=None, help="Output cleaned PDB path (optional)")
    ap.add_argument("--keep-all-models", action="store_true", help="Keep all models (default: keep only first)")
    ap.add_argument("--keep-waters", action="store_true", help="Keep waters (default: remove)")
    ap.add_argument("--keep-ions", action="store_true", help="Keep ions (default: remove)")
    ap.add_argument("--keep-hydrogens", action="store_true", help="Keep hydrogens (default: remove)")
    args = ap.parse_args()

    parser = PDBParser(QUIET=True)
    structure = parser.get_structure("struct", args.pdb_in)

    structure = clean_structure(
        structure,
        remove_waters=not args.keep_waters,
        remove_ions=not args.keep_ions,
        remove_h=not args.keep_hydrogens,
        keep_only_first_model=not args.keep_all_models,
    )

    report = audit_structure(structure)
    print_report(report)

    if args.out:
        io = PDBIO()
        io.set_structure(structure)
        io.save(args.out, select=CleanSelect())
        print(f"\nWrote cleaned PDB: {args.out}")


if __name__ == "__main__":
    main()