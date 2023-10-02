codeunit 6060013 "NPR NO Re-gen. Audit Signat."
{
    Access = Internal;

    trigger OnRun()
    var
        POSAuditLog: Record "NPR POS Audit Log";
        POSEntry: Record "NPR POS Entry";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        Selected: Integer;
        ChooseMsg: Label 'Choose one of the following options:';
        DirectSaleEndLbl: Label 'POS Direct Sale Ended';
        OptionsLbl: Label 'Recreate all transactions for signing, Add missed entries to Audit Log with Signing, Cancel';
    begin
        Selected := 2;
        if GuiAllowed then
            Selected := Dialog.StrMenu(OptionsLbl, 3, ChooseMsg);

        if (Selected = 3) or (Selected = 0) then
            exit;

        if Selected = 1 then begin
            POSAuditLog.SetRange("Action Type", POSAuditLog."Action Type"::DIRECT_SALE_END);
            POSAuditLog.DeleteAll(false);
        end;

        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.FindSet();
        repeat
            if not SalespersonPurchaser.Get(POSEntry."Salesperson Code") then begin
                SalespersonPurchaser.Init();
                SalespersonPurchaser.Code := POSEntry."Salesperson Code";
                SalespersonPurchaser.Insert();
            end;
            POSAuditLogMgt.CreateEntry(POSEntry.RecordId, POSAuditLog."Action Type"::GRANDTOTAL, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
            POSAuditLogMgt.CreateEntryExtended(POSEntry.RecordId, POSAuditLog."Action Type"::DIRECT_SALE_END, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.", DirectSaleEndLbl, '');
        until POSEntry.Next() = 0;
    end;
}