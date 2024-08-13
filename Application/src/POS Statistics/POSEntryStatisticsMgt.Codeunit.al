codeunit 6184978 "NPR POS Entry Statistics Mgt"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnCustomMethod', '', true, true)]
    local procedure OnRequestPOSData(Method: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        ResponseObject: JsonObject;
    begin
        case Method of
            'PosStats_GetPOSEntries':
                begin
                    Handled := true;
                    ResponseObject.Add('POSEntries', GetPOSEntries(Context));
                    FrontEnd.RespondToFrontEndMethod(Context, ResponseObject, FrontEnd);
                end;
            'PosStats_GetAvailableFields':
                begin
                    Handled := true;
                    ResponseObject.Add('POSEntries_AvailableFields', PosStats_GetAvailableFields());
                    FrontEnd.RespondToFrontEndMethod(Context, ResponseObject, FrontEnd);
                end;
        end;
    end;

    local procedure GetPOSEntries(Context: JsonObject): JsonArray
    var
        POSQuery: Query "NPR POS Entry Stats";
        POSEntriesArray: JsonArray;
    begin
        ApplyPOSEntryFilters(Context, POSQuery);
        POSQuery.Open();

        while POSQuery.Read() do begin
            POSEntriesArray.Add(CreateJsonObjectPOSEntry(POSQuery));
        end;

        POSQuery.Close();
        exit(POSEntriesArray);
    end;

    local procedure ApplyPOSEntryFilters(Context: JsonObject; POSQuery: Query "NPR POS Entry Stats")
    var
        JsonToken: JsonToken;
        FieldName: JsonToken;
        FieldValue: JsonToken;
        FiltersArray: JsonArray;

    begin
        if not Context.Get('filters', JsonToken) then
            exit;
        if not JsonToken.IsArray() then
            exit;

        FiltersArray := JsonToken.AsArray();

        foreach JsonToken in FiltersArray do begin
            JsonToken.AsObject().Get('Field', FieldName);
            JsonToken.AsObject().Get('Value', FieldValue);
            case FieldName.AsValue().AsText() of

                _POSEntry.FieldName("Entry No."):
                    POSQuery.SetFilter(POSQuery.Entry_No, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("POS Store Code"):
                    POSQuery.SetFilter(POSQuery.POS_Store_Code, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("POS Unit No."):
                    POSQuery.SetFilter(POSQuery.POS_Unit_No, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Salesperson Code"):
                    POSQuery.SetFilter(POSQuery.Salesperson_Code, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Responsibility Center"):
                    POSQuery.SetFilter(POSQuery.Responsibility_Center, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Document No."):
                    POSQuery.SetFilter(POSQuery.Document_No, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Entry Date"):
                    POSQuery.SetFilter(POSQuery.Entry_Date, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Posting Date"):
                    POSQuery.SetFilter(POSQuery.Posting_Date, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Entry Type"):
                    POSQuery.SetFilter(POSQuery.Entry_Type, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Customer No."):
                    POSQuery.SetFilter(POSQuery.Customer_No, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Reason Code"):
                    POSQuery.SetFilter(POSQuery.Reason_Code, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Amount Excl. Tax"):
                    POSQuery.SetFilter(POSQuery.Amount_Excl_Tax, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Tax Amount"):
                    POSQuery.SetFilter(POSQuery.Tax_Amount, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Amount Incl. Tax"):
                    POSQuery.SetFilter(POSQuery.Amount_Incl_Tax, FieldValue.AsValue().AsText());
                _POSEntry.FieldName("Payment Amount"):
                    POSQuery.SetFilter(POSQuery.Payment_Amount, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Line No."):
                    POSQuery.SetFilter(POSQuery.Line_No, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName(Type):
                    POSQuery.SetFilter(POSQuery.Type, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("No."):
                    POSQuery.SetFilter(POSQuery.No, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Variant Code"):
                    POSQuery.SetFilter(POSQuery.Variant_Code, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Location Code"):
                    POSQuery.SetFilter(POSQuery.Location_Code, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName(Quantity):
                    POSQuery.SetFilter(POSQuery.Quantity, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Unit of Measure Code"):
                    POSQuery.SetFilter(POSQuery.Unit_of_Measure_Code, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Quantity (Base)"):
                    POSQuery.SetFilter(POSQuery.Quantity_Base, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Unit Price"):
                    POSQuery.SetFilter(POSQuery.Unit_Price, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Unit Cost (LCY)"):
                    POSQuery.SetFilter(POSQuery.Unit_Cost_LCY, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("VAT %"):
                    POSQuery.SetFilter(POSQuery.VAT_Percent, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Line Discount %"):
                    POSQuery.SetFilter(POSQuery.Line_Discount_Percent, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Line Dsc. Amt. Excl. VAT (LCY)"):
                    POSQuery.SetFilter(POSQuery.Line_Dsc_Amt_Excl_VAT_LCY, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Line Dsc. Amt. Incl. VAT (LCY)"):
                    POSQuery.SetFilter(POSQuery.Line_Dsc_Amt_Incl_VAT_LCY, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Amount Excl. VAT (LCY)"):
                    POSQuery.SetFilter(POSQuery.Amount_Excl_VAT_LCY, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Amount Incl. VAT (LCY)"):
                    POSQuery.SetFilter(POSQuery.Amount_Incl_VAT_LCY, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Shortcut Dimension 1 Code"):
                    POSQuery.SetFilter(POSQuery.Sales_Line_Shortcut_Dimension_1_Code, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Shortcut Dimension 2 Code"):
                    POSQuery.SetFilter(POSQuery.Sales_Line_Shortcut_Dimension_2_Code, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("VAT Calculation Type"):
                    POSQuery.SetFilter(POSQuery.VAT_Calculation_Type, FieldValue.AsValue().AsText());
                _POSEntrySalesLine.FieldName("Return Reason Code"):
                    POSQuery.SetFilter(POSQuery.Return_Reason_Code, FieldValue.AsValue().AsText());
            end;
        end;
    end;

    local procedure CreateJsonObjectPOSEntry(POSQuery: Query "NPR POS Entry Stats"): JsonObject
    var
        JsonObject: JsonObject;
    begin
        JsonObject.Add(_POSEntry.FieldName("Entry No."), POSQuery.Entry_No);
        JsonObject.Add(_POSEntry.FieldName("POS Store Code"), POSQuery.POS_Store_Code);
        JsonObject.Add(_POSEntry.FieldName("POS Unit No."), POSQuery.POS_Unit_No);
        JsonObject.Add(_POSEntry.FieldName("Salesperson Code"), POSQuery.Salesperson_Code);
        JsonObject.Add(_POSEntry.FieldName("Responsibility Center"), POSQuery.Responsibility_Center);
        JsonObject.Add(_POSEntry.FieldName("Document No."), POSQuery.Document_No);
        JsonObject.Add(_POSEntry.FieldName("Entry Date"), POSQuery.Entry_Date);
        JsonObject.Add(_POSEntry.FieldName("Posting Date"), POSQuery.Posting_Date);
        JsonObject.Add(_POSEntry.FieldName("Entry Type"), POSQuery.Entry_Type);
        JsonObject.Add(_POSEntry.FieldName("Customer No."), POSQuery.Customer_No);
        JsonObject.Add(_POSEntry.FieldName("Reason Code"), POSQuery.Reason_Code);
        JsonObject.Add(_POSEntry.FieldName("Amount Excl. Tax"), POSQuery.Amount_Excl_Tax);
        JsonObject.Add(_POSEntry.FieldName("Tax Amount"), POSQuery.Tax_Amount);
        JsonObject.Add(_POSEntry.FieldName("Amount Incl. Tax"), POSQuery.Amount_Incl_Tax);
        JsonObject.Add(_POSEntry.FieldName("Payment Amount"), POSQuery.Payment_Amount);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Line No."), POSQuery.Line_No);
        JsonObject.Add(_POSEntrySalesLine.FieldName(Type), POSQuery.Type);
        JsonObject.Add(_POSEntrySalesLine.FieldName("No."), POSQuery.No);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Variant Code"), POSQuery.Variant_Code);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Location Code"), POSQuery.Location_Code);
        JsonObject.Add(_POSEntrySalesLine.FieldName(Quantity), POSQuery.Quantity);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Unit of Measure Code"), POSQuery.Unit_of_Measure_Code);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Quantity (Base)"), POSQuery.Quantity_Base);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Unit Price"), POSQuery.Unit_Price);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Unit Cost (LCY)"), POSQuery.Unit_Cost_LCY);
        JsonObject.Add(_POSEntrySalesLine.FieldName("VAT %"), POSQuery.VAT_Percent);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Line Discount %"), POSQuery.Line_Discount_Percent);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Line Dsc. Amt. Excl. VAT (LCY)"), POSQuery.Line_Dsc_Amt_Excl_VAT_LCY);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Line Discount Amount Incl. VAT"), POSQuery.Line_Dsc_Amt_Incl_VAT_LCY);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Amount Excl. VAT (LCY)"), POSQuery.Amount_Excl_VAT_LCY);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Amount Incl. VAT (LCY)"), POSQuery.Amount_Incl_VAT_LCY);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Shortcut Dimension 1 Code"), POSQuery.Sales_Line_Shortcut_Dimension_1_Code);
        JsonObject.Add(_POSEntrySalesLine.FieldName("Shortcut Dimension 2 Code"), POSQuery.Sales_Line_Shortcut_Dimension_2_Code);
        JsonObject.Add(_POSEntrySalesLine.FieldName("VAT Calculation Type"), Format(POSQuery.VAT_Calculation_Type));
        JsonObject.Add(_POSEntrySalesLine.FieldName("Return Reason Code"), POSQuery.Return_Reason_Code);
        exit(JsonObject);
    end;

    procedure PosStats_GetAvailableFields(): JsonArray
    var
        JsonArray: JsonArray;
    begin
        AddFieldToArray(_POSEntry.FieldName("Entry No."), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("POS Store Code"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("POS Unit No."), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Salesperson Code"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Responsibility Center"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Document No."), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Entry Date"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Posting Date"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Entry Type"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Customer No."), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Reason Code"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Amount Excl. Tax"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Tax Amount"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Amount Incl. Tax"), JsonArray);
        AddFieldToArray(_POSEntry.FieldName("Payment Amount"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Line No."), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName(Type), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("No."), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Variant Code"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Location Code"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName(Quantity), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Unit of Measure Code"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Quantity (Base)"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Unit Price"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Unit Cost (LCY)"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("VAT %"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Line Discount %"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Line Dsc. Amt. Excl. VAT (LCY)"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Line Dsc. Amt. Incl. VAT (LCY)"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Amount Excl. VAT (LCY)"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Amount Incl. VAT (LCY)"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Shortcut Dimension 1 Code"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Shortcut Dimension 2 Code"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("VAT Calculation Type"), JsonArray);
        AddFieldToArray(_POSEntrySalesLine.FieldName("Return Reason Code"), JsonArray);
        exit(JsonArray);
    end;

    local procedure AddFieldToArray(FieldName: Text; var JsonArray: JsonArray)
    JsonObject: JsonObject;
    begin
        JsonObject.Add('Field', FieldName);
        JsonArray.Add(JsonObject);
        Clear(JsonObject);
    end;

    var
        _POSEntry: Record "NPR POS Entry";
        _POSEntrySalesLine: REcord "NPR POS Entry Sales Line";
}