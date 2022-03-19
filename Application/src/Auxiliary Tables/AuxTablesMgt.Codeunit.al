codeunit 6014440 "NPR Aux. Tables Mgt."
{
    Access = Internal;
    procedure CopyValueEntryToAux(ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        AuxValueEntry: Record "NPR Aux. Value Entry";
    begin
        if AuxValueEntry.IsTemporary() then
            exit;

        AuxValueEntry.Init();
        AuxValueEntry.TransferFields(ValueEntry);

        AuxValueEntry."Item Category Code" := ItemJournalLine."Item Category Code";
        AuxValueEntry."Vendor No." := ItemJournalLine."NPR Vendor No.";
        AuxValueEntry."Discount Type" := ItemJournalLine."NPR Discount Type";
        AuxValueEntry."Discount Code" := ItemJournalLine."NPR Discount Code";
        AuxValueEntry."POS Unit No." := ItemJournalLine."NPR Register Number";
        AuxValueEntry."Group Sale" := ItemJournalLine."NPR Group Sale";
        AuxValueEntry."Salespers./Purch. Code" := ItemJournalLine."Salespers./Purch. Code";
        AuxValueEntry."Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", ItemJournalLine."NPR Document Time");

        AuxValueEntry.Insert();
    end;

    procedure CopyItemLedgerEntryToAux(ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line")
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
        OldAuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        if ItemLedgerEntry.IsTemporary() then
            exit;

        AuxItemLedgerEntry.Init();
        AuxItemLedgerEntry.TransferFields(ItemLedgerEntry);

        AuxItemLedgerEntry."Vendor No." := ItemJournalLine."NPR Vendor No.";
        AuxItemLedgerEntry."Discount Type" := ItemJournalLine."NPR Discount Type";
        AuxItemLedgerEntry."Discount Code" := ItemJournalLine."NPR Discount Code";
        AuxItemLedgerEntry."POS Unit No." := ItemJournalLine."NPR Register Number";
        AuxItemLedgerEntry."Group Sale" := ItemJournalLine."NPR Group Sale";
        AuxItemLedgerEntry."Salespers./Purch. Code" := ItemJournalLine."Salespers./Purch. Code";
        AuxItemLedgerEntry."Document Time" := ItemJournalLine."NPR Document Time";
        AuxItemLedgerEntry."Document Date and Time" := CreateDateTime(ItemJournalLine."Posting Date", AuxItemLedgerEntry."Document Time");

        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Transfer then begin
            OldAuxItemLedgerEntry.SetCurrentKey("New Entry No.");
            OldAuxItemLedgerEntry.SetRange("New Entry No.", ItemLedgerEntry."Entry No.");
            if OldAuxItemLedgerEntry.FindFirst() then begin
                AuxItemLedgerEntry."Vendor No." := OldAuxItemLedgerEntry."Vendor No.";
                AuxItemLedgerEntry."Item Category Code" := OldAuxItemLedgerEntry."Item Category Code";
                AuxItemLedgerEntry."POS Unit No." := OldAuxItemLedgerEntry."POS Unit No.";
                AuxItemLedgerEntry."Salespers./Purch. Code" := OldAuxItemLedgerEntry."Salespers./Purch. Code";

                OldAuxItemLedgerEntry."New Entry No." := 0;
                OldAuxItemLedgerEntry.Modify();
            end;
        end;

        AuxItemLedgerEntry.Insert();
    end;

    procedure UpdateAuxItemLedgerEntry(ItemLedgerEntry: Record "Item Ledger Entry")
    var
        AuxItemLedgerEntry: Record "NPR Aux. Item Ledger Entry";
    begin
        if ItemLedgerEntry.IsTemporary() then
            exit;

        if not AuxItemLedgerEntry.Get(ItemLedgerEntry."Entry No.") then
            exit;

        AuxItemLedgerEntry."Invoiced Quantity" := ItemLedgerEntry."Invoiced Quantity";
        AuxItemLedgerEntry.Modify();
    end;

    procedure CopyGLEntryToAux(GLEntry: Record "G/L Entry")
    var
        AuxGLEntry: Record "NPR Aux. G/L Entry";
    begin
        AuxGLEntry.Init();
        AuxGLEntry.TransferFields(GLEntry);
        AuxGLEntry.Insert();
    end;

    procedure GetAuxTableIdFromParentTable(IncomingTableId: Integer): Integer
    begin
        case IncomingTableId of
            Database::Item:
                exit(Database::"NPR Auxiliary Item");
            else
                exit(0);
        end;
    end;

    procedure InsertTemplateValuesFromAuxFields(var ConfigTemplateHeader: Record "Config. Template Header"; var RecRef: RecordRef; SkipFields: Boolean; var TempSkipFields: Record Field)
    var
        ConfigTemplateLine: Record "Config. Template Line";
        Item: Record Item;
        AuxItem: Record "NPR Auxiliary Item";
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
        FieldRef: FieldRef;
        AuxRecRef: RecordRef;
        SkipCurrentField: Boolean;
    begin
        case AuxTablesMgt.GetAuxTableIdFromParentTable(ConfigTemplateHeader."Table ID") of
            Database::"NPR Auxiliary Item":
                begin
                    RecRef.SetTable(Item);
                    Item.NPR_GetAuxItem(AuxItem);
                    AuxRecRef.GetTable(AuxItem);
                    ConfigTemplateLine.SetRange("Table ID", AuxTablesMgt.GetAuxTableIdFromParentTable(Database::Item));
                end;
            else
                exit;
        end;
        ConfigTemplateLine.SetRange("Data Template Code", ConfigTemplateHeader.Code);
        if ConfigTemplateLine.FindSet() then
            repeat
                case ConfigTemplateLine.Type of
                    ConfigTemplateLine.Type::Field:
                        if ConfigTemplateLine."Field ID" <> 0 then begin
                            if SkipFields then
                                SkipCurrentField := ShouldSkipField(TempSkipFields, ConfigTemplateLine."Field ID", ConfigTemplateLine."Table ID")
                            else
                                SkipCurrentField := false;

                            if not SkipCurrentField then begin
                                FieldRef := AuxRecRef.Field(ConfigTemplateLine."Field ID");
                                ModifyRecordWithField(AuxRecRef, FieldRef, ConfigTemplateLine."Default Value", ConfigTemplateLine."Language ID");
                            end;
                        end;
                end;
            until ConfigTemplateLine.Next() = 0;
    end;

    local procedure ModifyRecordWithField(var RecRef: RecordRef; FieldRef: FieldRef; Value: Text[250]; LanguageID: Integer)
    var
        ConfigValidateMgt: Codeunit "Config. Validate Management";
    begin
        ConfigValidateMgt.ValidateFieldValue(RecRef, FieldRef, Value, false, LanguageID);
        RecRef.Modify(true);
    end;

    local procedure ShouldSkipField(var TempSkipField: Record "Field"; CurrentFieldNo: Integer; CurrentTableNo: Integer): Boolean
    begin
        TempSkipField.Reset();
        exit(TempSkipField.Get(CurrentTableNo, CurrentFieldNo));
    end;

    procedure CreateAuxItemAccessoryLink(ItemNo: Code[20]; LastItemNo: Code[20]; HasAccessories: Boolean)
    var
        Item: Record Item;
        xItem: Record Item;
        AuxItem: Record "NPR Auxiliary Item";
        xAuxItem: Record "NPR Auxiliary Item";
    begin
        if xItem.Get(LastItemNo) then begin
            xItem.NPR_GetAuxItem(xAuxItem);
            xAuxItem."Has Accessories" := HasAccessories;
            xItem.NPR_SetAuxItem(xAuxItem);
            xItem.NPR_SaveAuxItem();
        end;
        if not Item.Get(ItemNo) then
            exit;
        Item.NPR_GetAuxItem(AuxItem);
        AuxItem."Has Accessories" := HasAccessories;
        Item.NPR_SetAuxItem(AuxItem);
        Item.NPR_SaveAuxItem();
    end;

}
