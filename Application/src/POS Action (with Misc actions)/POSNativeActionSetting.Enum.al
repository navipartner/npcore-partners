enum 6150825 "NPR POS Native Action Setting"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    Caption = 'POS Native Action Type';

    value(0; ADMISSION) { }
    value(1; EOD) { }
    value(2; PRINTLASTRECEIPT) { }
    value(3; SCANDITITEMINFO) { }
    value(4; SCANDITFINDITEM) { }
    value(7; ASSIGNTAG) { }
    value(8; LOCATETAG) { }
    value(11; SCANDITSCAN) { }
}
