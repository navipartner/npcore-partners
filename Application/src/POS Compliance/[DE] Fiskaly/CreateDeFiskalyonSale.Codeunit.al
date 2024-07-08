codeunit 6150984 "NPR Create De Fiskaly on Sale"
{
    Access = Internal;

    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        DEAuditMgt: Codeunit "NPR DE Audit Mgt.";
    begin
        DEAuditMgt.CreateDeFiskalyOnSale(Rec);
    end;
}