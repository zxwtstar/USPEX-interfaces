from ase.io.vasp import write_vasp
from ase import io
import sys

def cif2vaspUsingASE(cif_path, poscar_path):
    """
    ASE seems to do an excellent job with reading cif's.
    It will write out the coordinates in fraction coordinates.
    """
    atoms = io.read(cif_path)
    write_vasp(poscar_path, atoms, direct=True, vasp5=True)
    return len(atoms)

if __name__ == "__main__":
    assert len(sys.argv) == 3
    cif_path = sys.argv[1]
    poscar_path = sys.argv[2]
    N_atoms = cif2vaspUsingASE(cif_path, poscar_path)

    print('<CALLRESULT> ' + str(N_atoms))
