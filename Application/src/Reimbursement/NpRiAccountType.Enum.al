﻿enum 6151100 "NPR NpRi Account Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "G/L Account") { Caption = 'G/L Account'; }
    value(1; "Customer") { Caption = 'Customer'; }
    value(2; "Vendor") { Caption = 'Vendor'; }
    value(3; "Bank Account") { Caption = 'Bank Account'; }
    value(4; "Fixed Asset") { Caption = 'Fixed Asset'; }
    value(5; "IC Partner") { Caption = 'IC Partner'; }
    value(6; "Membership") { Caption = 'Membership'; }
}
