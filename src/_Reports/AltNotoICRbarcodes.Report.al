report 6014602 "NPR Alt. No. to ICR barcodes"
{
    Caption = 'Alt. No. to Item Cross Reference barcodes';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Alternative No."; "NPR Alternative No.")
        {
            DataItemTableView = WHERE(Type = CONST(Item), "Alt. No." = FILTER(<> ''));

            trigger OnAfterGetRecord()
            var
                ICR: Record "Item Cross Reference";
                Item: Record Item;
                ItemVariant: Record "Item Variant";
            begin
                ICR.SetRange("Cross-Reference Type", ICR."Cross-Reference Type"::"Bar Code");
                ICR.SetRange("Cross-Reference No.", "Alt. No.");
                ICR.SetFilter("Item No.", '<>%1', Code);
                ICR.SetFilter("Variant Code", '<>%1', "Variant Code");
                if not ICR.IsEmpty then
                    Error(Error_Clash, "Alt. No.", Code);

                ICR.Reset;

                ICR.Init;
                ICR."Item No." := Code;
                ICR."Variant Code" := "Variant Code";
                ICR."Unit of Measure" := "Base Unit of Measure";
                ICR."Cross-Reference Type" := ICR."Cross-Reference Type"::"Bar Code";
                ICR."Cross-Reference No." := "Alt. No.";
                ICR."Discontinue Bar Code" := Discontinue;

                if Item."No." <> Code then
                    if not Item.Get(Code) then
                        Clear(Item);

                if "Variant Code" = '' then
                    case VRTSetup."Item Cross Ref. Description(I)" of
                        VRTSetup."Item Cross Ref. Description(I)"::ItemDescription1:
                            ICR.Description := Item.Description;
                        VRTSetup."Item Cross Ref. Description(I)"::ItemDescription2:
                            ICR.Description := Item."Description 2";
                    end
                else begin
                    if not ItemVariant.Get(Code, "Variant Code") then
                        Clear(ItemVariant);
                    case VRTSetup."Item Cross Ref. Description(V)" of
                        VRTSetup."Item Cross Ref. Description(V)"::ItemDescription1:
                            ICR.Description := Item.Description;
                        VRTSetup."Item Cross Ref. Description(V)"::ItemDescription2:
                            ICR.Description := Item."Description 2";
                        VRTSetup."Item Cross Ref. Description(V)"::VariantDescription1:
                            ICR.Description := ItemVariant.Description;
                        VRTSetup."Item Cross Ref. Description(V)"::VariantDescription2:
                            ICR.Description := ItemVariant."Description 2";
                    end;
                end;

                if ICR.Insert then //Don't fail on barcodes that have already been moved.
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
                UpdateDialog(1, DATABASE::"NPR Alternative No.");
                Total := "Alternative No.".Count;
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

        VRTSetup.Get;
    end;

    trigger OnPostReport()
    begin
        Message(Txt_Success, AddCounter);
    end;

    var
        Txt_Warning: Label 'Warning:\This report will move all barcodes from alternative numbers to item cross references.This can take a long time depending on the data size and will lock the tables in the meantime.\\Are you sure you want to continue?';
        Txt_Success: Label '%1 barcodes were moved successfully to item cross reference table.';
        Error_Clash: Label 'Alt No. barcode %1 for item %2 already exists in ICR on a different item. Please resolve this conflict manually and run again. No changes were made.';
        AddCounter: Integer;
        VRTSetup: Record "NPR Variety Setup";
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

