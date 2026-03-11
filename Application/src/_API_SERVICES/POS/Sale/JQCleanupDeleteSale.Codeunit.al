codeunit 6151087 "NPR JQ Cleanup Delete Sale"
{
    Access = Internal;
    TableNo = "NPR POS Sale";

    trigger OnRun()
    begin
        Rec.Delete(true);
    end;
}
