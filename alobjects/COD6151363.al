codeunit 6151363 "CS UI Transfer Order Posting"
{
    // NPR5.51/CLVA/20180313 CASE 359268 Object created - NP Capture Service
    // NPR5.52/CLVA/20190926 CASE 370367 Changed interface

    TableNo = "CS Posting Buffer";

    trigger OnRun()
    var
        TransferPostReceipt: Codeunit "TransferOrder-Post Receipt";
        WarehouseActivityHeader: Record "Warehouse Activity Header";
        ReleaseTransferDoc: Codeunit "Release Transfer Document";
        TransferHeader: Record "Transfer Header";
        RecRef: RecordRef;
        TransferHeaderNo: Code[20];
    begin
        //-NPR5.52 [370367]
        TestField("Table No.");
        TestField("Record Id");
        RecRef.Open("Table No.");
        RecRef.Get("Record Id");
        RecRef.SetTable(TransferHeader);
        RecRef.SetRecFilter;
        TransferHeaderNo := TransferHeader."No.";
        //+NPR5.52 [370367]

        TransferPostReceipt.SetHideValidationDialog(true);
        if TransferPostReceipt.Run(TransferHeader) then begin

          if TransferHeader.Get(TransferHeaderNo) then begin

            if TransferHeader.Status = TransferHeader.Status::Released then
              ReleaseTransferDoc.Reopen(TransferHeader);

            TransferHeader.Delete(true);

          end;

        end;
    end;
}

