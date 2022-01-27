enum 6150753 "NPR Button Font Size"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    ObsoleteState = Pending;
    ObsoleteReason = 'Enum Is not needed anymore. Case 498936';
    Extensible = false;

    value(0; XSmall) { }
    value(1; Small) { }
    value(2; Normal) { }
    value(3; Medium) { }
    value(4; Semilarge) { }
    value(5; Large) { }
    value(6; XLarge) { }
}
