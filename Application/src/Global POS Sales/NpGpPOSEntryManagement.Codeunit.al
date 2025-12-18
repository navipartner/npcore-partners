codeunit 6151163 "NPR NpGp POS Entry Management"
{
    Access = Internal;
    TableNo = "NPR NpGp POS Sales Entry";

    internal procedure PrintEntry(NpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry")
    var
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
    begin
        NpGpPOSSalesEntry.SetRecFilter();
        RecRef.GetTable(NpGpPOSSalesEntry);
        RetailReportSelectionMgt.SetRegisterNo(NpGpPOSSalesEntry."POS Unit No.");
        case NpGpPOSSalesEntry."Entry Type" of
            NpGpPOSSalesEntry."Entry Type"::"Direct Sale", NpGpPOSSalesEntry."Entry Type"::"Credit Sale":
                RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Large Sales Receipt (Global POS Entry)".AsInteger());
        end;
    end;
}
