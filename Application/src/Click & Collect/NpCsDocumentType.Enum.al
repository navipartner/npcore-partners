﻿enum 6151198 "NPR NpCs Document Type"
{
    #IF NOT BC17  
    Access = Internal;       
    #ENDIF
    Extensible = true;
    AssignmentCompatibility = true;

    value(0; "Quote") { Caption = 'Quote'; }
    value(1; "Order") { Caption = 'Order'; }
    value(2; "Invoice") { Caption = 'Invoice'; }
    value(3; "Credit Memo") { Caption = 'Credit Memo'; }
    value(4; "Blanket Order") { Caption = 'Blanket Order'; }
    value(5; "Return Order") { Caption = 'Return Order'; }
    value(6; "Posted Invoice") { Caption = 'Posted Invoice'; }
    value(7; "Posted Credit Memo") { Caption = 'Posted Credit Memo'; }
}
