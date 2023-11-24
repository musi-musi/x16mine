%import syslib
%import veradat

vram {

    ubyte[256] segments

    sub load() {
        cx16.rambank(4);
        veradat.loadFileToBank("palette.dat");
        veradat.uploadVram();
        cx16.rambank(4);
        veradat.loadFileToBank("vera.dat");
        veradat.copySegmentTable(&segments);
        veradat.uploadVram();
    }

    sub getSegmentStart(uword segment) -> uword {
        return veradat.getSegmentStart(&segments, segment);
    }
    sub getSegmentStartH(uword segment) -> ubyte {
        return veradat.getSegmentStartH(&segments, segment);
    }


}