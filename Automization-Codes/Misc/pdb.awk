BEGIN {
    # Record Format (copied from http://www.wwpdb.org/documentation/file-format-content/format33/sect9.html#ATOM)
    #
    #                 COLUMNS        DATA  TYPE    FIELD        DEFINITION
    #                 -------------------------------------------------------------------------------------
    flds[++numFlds]="  1 -  6        Record name   ATOM  "
    flds[++numFlds]="  7 - 11        Integer       serial       Atom  serial number."
    flds[++numFlds]=" 13 - 16        Atom          name         Atom name."
    flds[++numFlds]=" 17             Character     altLoc       Alternate location indicator."
    flds[++numFlds]=" 18 - 20        Residue name  resName      Residue name."
    flds[++numFlds]=" 22             Character     chainID      Chain identifier."
    flds[++numFlds]=" 23 - 26        Integer       resSeq       Residue sequence number."
    flds[++numFlds]=" 27             AChar         iCode        Code for insertion of residues."
    flds[++numFlds]=" 31 - 38        Real(8.3)     x            Orthogonal coordinates for X in Angstroms."
    flds[++numFlds]=" 39 - 46        Real(8.3)     y            Orthogonal coordinates for Y in Angstroms."
    flds[++numFlds]=" 47 - 54        Real(8.3)     z            Orthogonal coordinates for Z in Angstroms."
    flds[++numFlds]=" 55 - 60        Real(6.2)     occupancy    Occupancy."
    flds[++numFlds]=" 61 - 66        Real(6.2)     tempFactor   Temperature  factor."
    flds[++numFlds]=" 77 - 78        LString(2)    element      Element symbol, right-justified."
    flds[++numFlds]=" 79 - 80        LString(2)    charge       Charge  on the atom."

    for (fldNr=1; fldNr<=numFlds; fldNr++) {
        fld = flds[fldNr]

        cols = substr(fld,1,16)
        gsub(/ /,"",cols)
        n = split(cols,begEnd,/-/)

        tag  = substr(fld,31,13)
        gsub(/ /,"",tag)

        tags[fldNr] = tag
        begs[tag] = begEnd[1]
        wids[tag] = begEnd[n] - begEnd[1] + 1

        # Uncomment this if interested in the values the arrays contain:
        # print "<" fldNr "><" tags[fldNr] "><" begs[tag] "><" wids[tag] ">" | "cat>&2"
    }
}

{
    for (fldNr=1; fldNr<=numFlds; fldNr++) {
        tag = tags[fldNr]
        f[tag] = substr($0,begs[tag],wids[tag])
        gsub(/^ +| +$/,"",f[tag])
    }
}

f["resName"] == "AP1" { f["resName"] = "ASP" }     # this is where you can change a field by its tag/name

{
    for (fldNr=1; fldNr<=numFlds; fldNr++) {
        tag = tags[fldNr]
        printf "%-*s", wids[tag], f[tag]
    }
    print ""
}
