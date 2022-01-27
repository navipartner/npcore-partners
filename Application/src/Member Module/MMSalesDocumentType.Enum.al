enum 6059771 "NPR MM Sales Document Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "0") { Caption = ' '; }
    value(1; "1") { Caption = '1'; }
    value(2; "2") { Caption = '2'; }
    value(3; "3") { Caption = '3'; }
    value(4; "4") { Caption = '4'; }
    value(5; "5") { Caption = '5'; }
}
