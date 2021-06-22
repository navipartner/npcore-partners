codeunit 6060056 "NPR Item Wksht. Doc. Exch."
{
    procedure InsertItemWorksheetLine(ItemWorksheet: Record "NPR Item Worksheet"; var ItemWorksheetLine: Record "NPR Item Worksheet Line"; VendorNo: Code[20]; VendorItemNo: Text; VendorItemDescription: Text; ItemGroupText: Text; DirectUnitCost: Decimal)
    var
        ItemCategory: Record "Item Category";
        LastItemWorksheetLine: Record "NPR Item Worksheet Line";
        ItemWorksheetLineNo: Integer;
    begin
        ItemWorksheetLine.SetRange("Worksheet Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", ItemWorksheet.Name);
        if ItemWorksheetLine.FindLast() then begin
            LastItemWorksheetLine := ItemWorksheetLine;
            ItemWorksheetLineNo := ItemWorksheetLine."Line No." + 10000
        end else begin
            LastItemWorksheetLine.Init();
            ItemWorksheetLineNo := 10000;
        end;
        ItemWorksheetLine.Init();
        ItemWorksheetLine.Validate("Worksheet Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheetLine.Validate("Worksheet Name", ItemWorksheet.Name);
        ItemWorksheetLine.Validate("Line No.", ItemWorksheetLineNo);
        ItemWorksheetLine.Insert(true);
        ItemWorksheetLine."Created Date Time" := CurrentDateTime();
        ItemWorksheetLine.Validate("Vendor No.", VendorNo);
        ItemWorksheetLine.SetUpNewLine(LastItemWorksheetLine);
        ItemWorksheetLine.Action := ItemWorksheetLine.Action::CreateNew;
        if (ItemGroupText <> '') and (StrLen(ItemGroupText) <= MaxStrLen(ItemCategory.Code)) then
            if ItemCategory.Get(ItemGroupText) then
                ItemWorksheetLine.Validate("Item Category Code", ItemGroupText);
        ItemWorksheetLine.Validate("Vendor Item No.", CopyStr(VendorItemNo, 1, MaxStrLen(ItemWorksheetLine."Vendor Item No.")));
        ItemWorksheetLine.Validate(Description, CopyStr(VendorItemDescription, 1, MaxStrLen(ItemWorksheetLine.Description)));
        ItemWorksheetLine.Validate("Direct Unit Cost", DirectUnitCost);
        ItemWorksheetLine.Modify(true);

        OnAfterInsertItemWorksheetLine(ItemWorksheetLine);
    end;

    local procedure InsertItemWorksheetAttributeValues(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 1", 1, ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 2", 2, ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 3", 3, ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 4", 4, ItemWorksheetLine);
        InsertItemWorksheetAttributeValue(ItemWorksheetLine."Custom Text 5", 5, ItemWorksheetLine);
    end;

    local procedure InsertItemWorksheetAttributeValue(AttributeValue: Text; AttributeNo: Integer; ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
    begin
        if AttributeValue = '' then
            exit;

        NPRAttributeID.SetRange("Table ID", DATABASE::"NPR Item Worksheet Line");
        NPRAttributeID.SetRange("Shortcut Attribute ID", AttributeNo);
        if NPRAttributeID.FindFirst() then
            NPRAttributeManagement.SetWorksheetLineAttributeValue(
                    NPRAttributeID."Table ID", NPRAttributeID."Shortcut Attribute ID",
                    ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name",
                    ItemWorksheetLine."Line No.", AttributeValue);
    end;


    local procedure InsertItemWorksheetVariantLine(IncomingDocument: Record "Incoming Document"; ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ErrorMessage: Record "Error Message";
        ErrorMessage2: Record "Error Message";
        ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        ErrorMessage.SetRange("Context Record ID", IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number", DATABASE::"NPR Item Worksh. Variant Line");
        ErrorMessage.SetRange("Field Number", ItemWorksheetVariantLine.FieldNo(Description));
        ErrorMessage.SetRange(Description, ItemWorksheetLine."Vendor Item No.");
        if not ErrorMessage.FindFirst() then
            exit;

        ItemWorksheetVariantLine.Init();
        ItemWorksheetVariantLine.Validate("Worksheet Template Name", ItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetVariantLine.Validate("Worksheet Name", ItemWorksheetLine."Worksheet Name");
        ItemWorksheetVariantLine.Validate("Worksheet Line No.", ItemWorksheetLine."Line No.");
        ItemWorksheetVariantLine.Validate("Line No.", 10000);
        ItemWorksheetVariantLine.Insert(true);
        ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew;
        ItemWorksheetVariantLine.Validate("Item No.", ItemWorksheetLine."Item No.");
        ItemWorksheetVariantLine.Validate("Sales Price", ItemWorksheetLine."Sales Price");
        ItemWorksheetVariantLine.Validate("Direct Unit Cost", ItemWorksheetLine."Direct Unit Cost");
        ItemWorksheetVariantLine.Modify(true);
        ErrorMessage2.SetRange("Context Record ID", IncomingDocument.RecordId);
        ErrorMessage2.SetRange("Table Number", DATABASE::"NPR Item Worksh. Variant Line");
        ErrorMessage2.SetRange("Record ID", ErrorMessage2."Record ID");
        if ErrorMessage2.FindSet() then
            repeat
                if ErrorMessage2."Field Number" <> ItemWorksheetVariantLine.FieldNo(Description) then begin
                    RecRef.Get(ItemWorksheetVariantLine.RecordId);
                    FldRef := RecRef.Field(ErrorMessage2."Field Number");
                    FldRef.Value := CopyStr(ErrorMessage2.Description, 1, FldRef.Length);
                    RecRef.Modify();
                end;
            until ErrorMessage2.Next() = 0;
    end;

    procedure ItemWorksheetExists(ItemWorksheet: Record "NPR Item Worksheet"; ItemWorksheetLine: Record "NPR Item Worksheet Line"; VendorNo: Text; VendorItemNo: Text): Boolean
    var
        ItemWorksheetLine2: Record "NPR Item Worksheet Line";
    begin
        ItemWorksheetLine2.SetRange("Worksheet Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheetLine2.SetRange("Worksheet Name", ItemWorksheet.Name);
        ItemWorksheetLine2.SetFilter("Vendor No.", VendorNo);
        ItemWorksheetLine2.SetFilter("Vendor Item No.", VendorItemNo);
        if ItemWorksheetLine2.FindLast() then
            exit(true)
        else
            exit(false);
    end;

    local procedure CreateItemWorksheetLinesFromIncomingDocument(IncomingDocument: Record "Incoming Document")
    var
        ErrorMessage: Record "Error Message";
        ErrorMessage2: Record "Error Message";
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        DirectUnitCost: Decimal;
        NoOfMissingItems: Integer;
        ItemGroupText: Text;
        VendorItemDescription: Text;
        VendorItemNo: Text;
        VendorNo: Text;
    begin
        NoOfMissingItems := 0;
        ErrorMessage.SetRange("Context Record ID", IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number", DATABASE::"NPR Item Worksheet Line");
        ErrorMessage.SetRange("Field Number", ItemWorksheetLine.FieldNo("Vendor Item No."));
        if ErrorMessage.FindSet() then
            repeat
                NoOfMissingItems := NoOfMissingItems + 1;
                ErrorMessage2.Reset();
                ErrorMessage2.SetRange("Context Record ID", IncomingDocument.RecordId);
                ErrorMessage2.SetRange("Table Number", DATABASE::"NPR Item Worksheet Line");
                if ErrorMessage2.FindSet() then
                    repeat
                        if Format(ErrorMessage2."Record ID") = Format(ErrorMessage."Record ID") then begin
                            case ErrorMessage2."Field Number" of
                                ItemWorksheetLine.FieldNo("Vendor Item No."):
                                    VendorItemNo := ErrorMessage2.Description;
                                ItemWorksheetLine.FieldNo("Item Category Code"):
                                    ItemGroupText := ErrorMessage2.Description;
                                ItemWorksheetLine.FieldNo(Description):
                                    VendorItemDescription := ErrorMessage2.Description;
                                ItemWorksheetLine.FieldNo("Vendor No."):
                                    VendorNo := ErrorMessage2.Description;
                                ItemWorksheetLine.FieldNo("Direct Unit Cost"):
                                    begin
                                        Evaluate(DirectUnitCost, ErrorMessage2.Description, 9);
                                        Clear(DirectUnitCost);
                                    end;
                            end;
                        end;
                    until ErrorMessage2.Next() = 0;
                ErrorMessage.Modify(true);
            until ErrorMessage.Next() = 0;
        ErrorMessage.Reset();
        ErrorMessage.SetRange("Context Record ID", IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number", DATABASE::"NPR Item Worksheet Line");
        ErrorMessage.SetFilter("Field Number", '<>%1', ItemWorksheetLine.FieldNo("Vendor Item No."));
        ErrorMessage.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Incoming Document", 'OnAfterCreateDocFromIncomingDocFail', '', true, true)]
    local procedure OnAfterCreateDocFromIncomingDocFailCreateItemWorksheetLines(var IncomingDocument: Record "Incoming Document")
    begin
        CreateItemWorksheetLinesFromIncomingDocument(IncomingDocument);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Incoming Document", 'OnCheckIncomingDocCreateDocRestrictions', '', true, true)]
    local procedure OnCheckIncomingDocCreateDocRestrictionsCheckReopen(var Sender: Record "Incoming Document")
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID", Sender.RecordId);
        ErrorMessage.SetRange("Table Number", DATABASE::"NPR Item Worksheet Line");
        if not ErrorMessage.FindFirst() then
            exit;
        Sender.TestField(Released, false);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInsertItemWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;
}

