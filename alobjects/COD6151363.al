codeunit 6151363 "CS UI Transfer Order Posting"
{
    // NPR5.51/CLVA/20180313 CASE 359268 Object created - NP Capture Service

    TableNo = "Transfer Header";

    trigger OnRun()
    var
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
        TransferHeader: Record "Transfer Header";
    begin
        TransferPostReceipt.SetHideValidationDialog(true);
        if TransferPostReceipt.Run(Rec) then begin

          if TransferHeader.Get(Rec."No.") then begin

            if TransferHeader.Status = TransferHeader.Status::Released then
              ReleaseTransferDoc.Reopen(TransferHeader);

            TransferHeader.Delete(true);

          end;

        end;
    end;
}

