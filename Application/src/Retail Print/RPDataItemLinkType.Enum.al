enum 6014535 "NPR RP Data Item Link Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "=") { }
    value(1; ">") { }
    value(2; "<") { }
    value(3; "<>") { }
}