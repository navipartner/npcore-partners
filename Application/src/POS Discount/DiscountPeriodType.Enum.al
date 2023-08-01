enum 6014557 "NPR Discount Period Type"
{
#IF NOT BC17
    Access = Internal;
#ENDIF
    Extensible = false;

    value(0; "Every Day") { }
    value(1; Weekly) { }
}
