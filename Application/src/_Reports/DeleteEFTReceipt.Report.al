report 6014515 "NPR Delete EFT Receipt"
{
    // NPR5.55/TJ  /20200511 CASE 404177 New object

    UsageCategory = None;
    Caption = 'Delete EFT Receipt';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Company; Company)
        {
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Control6014401)
                {
                    ShowCaption = false;
                    field(EFTReceiptLogDateFormula; EFTReceiptLogDateFormula)
                    {
                        Caption = 'EFT Receipt Date Formula';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the EFT Receipt Date Formula field';
                    }
                    field(MaxSizeToDelete; MaxSizeToDelete)
                    {
                        Caption = 'Max. Size of Data to Delete';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Max. Size of Data to Delete field';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            EFTReceiptLogDateFormula := '<-5Y>';
            MaxSizeToDelete := 500000;
        end;
    }

    labels
    {
    }

    var
        EFTReceiptLogDateFormula: Text;
        MaxSizeToDelete: Decimal;

    procedure DeleteEFTReceipt(CompanyToDelete: Text[50]; LastDateToDelete: Date)
    var
        EFTReceipt: Record "NPR EFT Receipt";
        RecRef: RecordRef;
        NoOfEntries: Integer;
        NoOfRowsToDeleteAllowed: Integer;
        Counter: Integer;
        OriginalMaxSizeToDelete: Integer;
    begin
        if LastDateToDelete = 0D then
            exit;

        if CompanyToDelete = '' then
            exit;

        EFTReceipt.ChangeCompany(CompanyToDelete);
        EFTReceipt.SetRange(Date, 0D, LastDateToDelete);

        //Set the Best Key
        RecRef.GetTable(EFTReceipt);
        RecRef.CurrentKeyIndex(GetBestKey(RecRef));
        RecRef.SetTable(EFTReceipt);

        NoOfEntries := EFTReceipt.Count;
        NoOfRowsToDeleteAllowed := 0;
        OriginalMaxSizeToDelete := MaxSizeToDelete;
        Counter := 0;
        NoOfRowsToDeleteAllowed := GetNoOfRowsToDelete(CompanyToDelete, DATABASE::"NPR EFT Receipt", NoOfEntries);
        if (OriginalMaxSizeToDelete <> 0) then begin
            if (NoOfRowsToDeleteAllowed <> 0) then begin
                NoOfEntries := NoOfRowsToDeleteAllowed;
                if EFTReceipt.FindSet then
                    repeat
                        EFTReceipt.Delete;
                        Counter += 1;
                        EFTReceipt.Next;
                    until Counter = NoOfRowsToDeleteAllowed;
            end;
        end else
            EFTReceipt.DeleteAll;
        Commit;
    end;

    procedure GetBestKey(var RecRef: RecordRef): Integer
    var
        TMPInt: Record "Integer" temporary;
        KRef: KeyRef;
        FRef: FieldRef;
        BestKeyNo: Integer;
        BestScore: Integer;
        Score: Integer;
        Qty: Integer;
        i: Integer;
        j: Integer;
    begin
        //The function returns the index of the best key to use given the applied filters.
        BestKeyNo := 1;

        //Enumerate all fields with filter. Temporary record used for speed.
        for i := 1 to RecRef.FieldCount do begin
            FRef := RecRef.FieldIndex(i);
            while (not TMPInt.Get(FRef.Number)) and (j <= 255) do begin
                RecRef.FilterGroup(j);
                if FRef.GetFilter <> '' then begin
                    TMPInt.Init;
                    TMPInt.Number := FRef.Number;
                    TMPInt.Insert(false);
                end;
                j += 1;
            end;
            Clear(FRef);
            j := 0;
        end;

        //Loop through all keys to find best match.
        for i := 1 to RecRef.KeyCount do begin
            Clear(Score);
            Clear(Qty);
            KRef := RecRef.KeyIndex(i);
            for j := 1 to KRef.FieldCount do begin
                FRef := KRef.FieldIndex(j);
                if TMPInt.Get(FRef.Number) then begin
                    //Score for Placement:
                    Score += Power(2, 20 - j);
                    //Score for Quantity:
                    Qty += 1;
                    Score += Power(2, 20 - j) * (Qty - 1)
                end;
                Clear(FRef);
            end;
            if Score > BestScore then begin
                BestKeyNo := i;
                BestScore := Score;
            end;
        end;

        exit(BestKeyNo);
    end;

    local procedure GetNoOfRowsToDelete(CompanyToDelete: Text; "Table": Integer; OriginalRowCount: Integer): Integer
    var
        ActualRecordSizeToDelete: Integer;
        NoOfRowstodelete: Integer;
        TableInformation: Record "Table Information";
    begin
        if OriginalRowCount = 0 then
            exit(0);
        if MaxSizeToDelete = 0 then
            exit(0);
        if MaxSizeToDelete > 0 then begin
            TableInformation.SetRange(TableInformation."Company Name", CompanyToDelete);
            TableInformation.SetRange(TableInformation."Table No.", Table);
            if TableInformation.FindFirst then begin
                ActualRecordSizeToDelete := Round((OriginalRowCount * TableInformation."Record Size") / 1000, 1, '=');
                if MaxSizeToDelete > ActualRecordSizeToDelete then begin
                    MaxSizeToDelete := MaxSizeToDelete - ActualRecordSizeToDelete;
                    exit(OriginalRowCount);
                end else begin
                    NoOfRowstodelete := Round((MaxSizeToDelete / TableInformation."Record Size") * 1000, 1, '=');
                    MaxSizeToDelete := 0;
                    exit(NoOfRowstodelete);
                end;
            end;
        end else
            exit(OriginalRowCount);
    end;
}

