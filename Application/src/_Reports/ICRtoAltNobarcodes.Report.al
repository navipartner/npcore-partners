report 6014603 "NPR ICR to Alt. No. barcodes"
{
    Caption = 'Item Cross Reference to Alt. No. barcodes';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Item Cross Reference"; "Item Cross Reference")
        {
            DataItemTableView = WHERE("Cross-Reference No." = FILTER(<> ''), "Cross-Reference Type" = CONST("Bar Code"));

            trigger OnAfterGetRecord()
            var
                AltNo: Record "NPR Alternative No.";
            begin
                AltNo.SetRange(Type, AltNo.Type::Item);
                AltNo.SetRange("Alt. No.", "Cross-Reference No.");
                AltNo.SetFilter(Code, '<>%1', "Item No.");
                AltNo.SetFilter("Variant Code", '<>%1', "Variant Code");
                if not AltNo.IsEmpty then
                    Error(Error_Clash, "Cross-Reference No.", "Item No.");

                AltNo.Reset;

                AltNo.Init;
                AltNo.Code := "Item No.";
                AltNo."Variant Code" := "Variant Code";
                AltNo."Base Unit of Measure" := "Unit of Measure";
                AltNo.Type := AltNo.Type::Item;
                AltNo."Alt. No." := "Cross-Reference No.";
                AltNo.Discontinue := "Discontinue Bar Code";
                if AltNo.Insert then //Don't fail on barcodes that have already been moved.
                    AddCounter += 1;

                Delete;

                Itt += 1;
                UpdateProgressDialog(2, Itt, Total);
            end;

            trigger OnPostDataItem()
            begin
                CloseDialog();
            end;

            trigger OnPreDataItem()
            begin
                OpenDialog();
                UpdateDialog(1, DATABASE::"Item Cross Reference");
                Total := "Item Cross Reference".Count;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        if not Confirm(Txt_Warning) then
            exit;
    end;

    trigger OnPostReport()
    begin
        Message(Txt_Success, AddCounter);
    end;

    var
        Txt_Warning: Label 'Warning:\This report will move all barcodes from item cross references to alternative numbers.This can take a long time depending on the data size and will lock the tables in the meantime.\\Are you sure you want to continue?';
        Txt_Success: Label '%1 barcodes were moved successfully to alternative number table.';
        Error_Clash: Label 'Item cross reference barcode %1 for item %2 already exists as an Alt. No. on a different item. Please resolve this conflict manually and run again. No changes were made.';
        AddCounter: Integer;
        IsDialogOpen: Boolean;
        DialogValues: array[2] of Integer;
        ProgressDialog: Dialog;
        Itt: Integer;
        Total: Integer;

    local procedure "// Dialog"()
    begin
    end;

    local procedure OpenDialog()
    begin
        if GuiAllowed then
            if not IsDialogOpen then begin
                ProgressDialog.Open('Table ##1######\@@2@@@@@@@@@@@@@@@@@');
                IsDialogOpen := true;
            end;
    end;

    local procedure UpdateDialog(ValueNo: Integer; Value: Integer)
    begin
        if GuiAllowed then
            ProgressDialog.Update(ValueNo, Value);
    end;

    local procedure UpdateProgressDialog(ValueNo: Integer; Progress: Integer; Total: Integer)
    begin
        if GuiAllowed then begin
            Progress := Round(Progress / Total * 10000, 1, '>');
            if Progress <> DialogValues[ValueNo] then begin
                DialogValues[ValueNo] := Progress;
                ProgressDialog.Update(ValueNo, DialogValues[ValueNo]);
            end;
        end;
    end;

    local procedure CloseDialog()
    begin
        if GuiAllowed then
            ProgressDialog.Close;

        IsDialogOpen := false;
    end;
}

