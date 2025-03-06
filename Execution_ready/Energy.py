import sys
import subprocess

def get_energy_from_log(file_path, pattern, index):
    result = subprocess.run(['grep', pattern, file_path], capture_output=True, text=True)
    if result.stdout:
        return float(result.stdout.split()[index])
    return None

def main(arg):
    if arg == "RC":
        B1 = get_energy_from_log(f"{arg}_dlfind.log", 'Final converged energy', -1)
    elif arg in ["TS", "RB_TS"]:
        B1 = get_energy_from_log(f"{arg}_Opt.log", 'Final converged energy', -1)
        subprocess.run(['grep', 'frequencies', 'Frequency/*.log', '|', 'head', '-n', '4'])
    else:
        B1 = get_energy_from_log(f"{arg}_Opt.log", 'Final converged energy', -1)

    B2 = get_energy_from_log(f"SP/{arg}_SP.log", 'Energy (     hybrid):', -2)
    ZPE_KJ = get_energy_from_log(f"Frequency/{arg}_Freq.log", 'total ZPE', -2)
    ZPE = ZPE_KJ / (1000 * 4.184 * 627.5095) if ZPE_KJ else None
    B3 = B2 + ZPE if B2 and ZPE else None

    print(f"{arg}")
    print(f"QM(B1)/MM Energy = {B1} a.u.")
    print(f"QM(B2)/MM Energy = {B2} a.u.")
    print(f"QM(B3)/MM Energy = {B3} a.u.")
    print(f"ZPE_KJ = {ZPE_KJ}")
    print(f"ZPE(B1) = {ZPE}")

    with open(f"{arg}_energy.csv", 'w') as f:
        f.write(f"{B1}\t{B2}\t{ZPE_KJ}\n")

    subprocess.run(['xclip', '-selection', 'clipboard'], input=f"{B1}\t{B2}\t{ZPE_KJ}\n", text=True)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python Energy.py <argument>")
        sys.exit(1)
    main(sys.argv[1])
