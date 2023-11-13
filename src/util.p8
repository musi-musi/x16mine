%import syslib
%import string

util {

    sub loadFile(str name, uword address) {
        cbm.SETLFS(4, 8, 0)
        cbm.SETNAM(string.length(name), name)
        void cbm.LOAD(0, address)
    }
}