codeunit 6060056 "NPR Item Wksht. Doc. Exch."
{
    Access = Internal;
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
        ItemWorksheetLine.Validate("Vend Item No.", CopyStr(VendorItemNo, 1, MaxStrLen(ItemWorksheetLine."Vend Item No.")));
        ItemWorksheetLine.Validate(Description, CopyStr(VendorItemDescription, 1, MaxStrLen(ItemWorksheetLine.Description)));
        ItemWorksheetLine.Validate("Direct Unit Cost", DirectUnitCost);
        ItemWorksheetLine.Modify(true);

        OnAfterInsertItemWorksheetLine(ItemWorksheetLine);
    end;

    procedure ItemWorksheetExists(ItemWorksheet: Record "NPR Item Worksheet"; ItemWorksheetLine: Record "NPR Item Worksheet Line"; VendorNo: Text; VendorItemNo: Text): Boolean
    var
        ItemWorksheetLine2: Record "NPR Item Worksheet Line";
    begin
        ItemWorksheetLine2.SetRange("Worksheet Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheetLine2.SetRange("Worksheet Name", ItemWorksheet.Name);
        ItemWorksheetLine2.SetFilter("Vendor No.", VendorNo);
        ItemWorksheetLine2.SetFilter("Vend Item No.", VendorItemNo);
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
        ErrorMessage.SetRange("Field Number", ItemWorksheetLine.FieldNo("Vend Item No."));
        if ErrorMessage.FindSet() then
            repeat
                NoOfMissingItems := NoOfMissingItems + 1;
                ErrorMessage2.Reset();
                ErrorMessage2.SetRange("Context Record ID", IncomingDocument.RecordId);
                ErrorMessage2.SetRange("Table Number", DATABASE::"NPR Item Worksheet Line");
                if ErrorMessage2.FindSet() then
                    repeat
                        if Format(ErrorMessage2."Record ID") = Format(ErrorMessage."Record ID") then begin
#IF BC17 or BC18 or BC19 or BC20 or BC21
#pragma warning disable AL0432
                            case ErrorMessage2."Field Number" of
                                ItemWorksheetLine.FieldNo("Vend Item No."):
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
#pragma warning restore AL0432
#ELSE
                            case ErrorMessage2."Field Number" of
                                ItemWorksheetLine.FieldNo("Vend Item No."):
                                    VendorItemNo := ErrorMessage2.Message;
                                ItemWorksheetLine.FieldNo("Item Category Code"):
                                    ItemGroupText := ErrorMessage2.Message;
                                ItemWorksheetLine.FieldNo(Description):
                                    VendorItemDescription := ErrorMessage2.Message;
                                ItemWorksheetLine.FieldNo("Vendor No."):
                                    VendorNo := ErrorMessage2.Message;
                                ItemWorksheetLine.FieldNo("Direct Unit Cost"):
                                    begin
                                        Evaluate(DirectUnitCost, ErrorMessage2.Message, 9);
                                        Clear(DirectUnitCost);
                                    end;
                            end;
#ENDIF

                        end;
                    until ErrorMessage2.Next() = 0;
                ErrorMessage.Modify(true);
            until ErrorMessage.Next() = 0;
        ErrorMessage.Reset();
        ErrorMessage.SetRange("Context Record ID", IncomingDocument.RecordId);
        ErrorMessage.SetRange("Table Number", DATABASE::"NPR Item Worksheet Line");
        ErrorMessage.SetFilter("Field Number", '<>%1', ItemWorksheetLine.FieldNo("Vend Item No."));
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
    internal procedure OnAfterInsertItemWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;
}

