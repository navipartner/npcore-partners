codeunit 6059968 "NPR POS Action Transfer Order"
{
    Access = Internal;

    procedure CreateTransferOrder(POSStore: Record "NPR POS Store"; POSUnit: Record "NPR POS Unit"; TransferToCodeString: Text)
    var
        Location: Record Location;
        TransferHeader: Record "Transfer Header";
        TransferOrder: Page "Transfer Order";
    begin
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", POSStore."Location Code");
        if Location.Get(CopyStr(TransferToCodeString, 1, MaxStrLen(Location.Code))) then
            if not Location."Use As In-Transit" and (TransferHeader."Transfer-from Code" <> Location.Code) then
                TransferHeader.Validate("Transfer-to Code", TransferToCodeString);
        TransferHeader.Validate("Shortcut Dimension 1 Code", POSUnit."Global Dimension 1 Code");
        TransferHeader.Modify();

        TransferHeader.SetRange("No.", TransferHeader."No.");
        TransferOrder.SetTableView(TransferHeader);

        TransferOrder.Run();
    end;
}
