codeunit 6059921 "NPR POS Entry Lines WS"
{
    Access = Internal;

    trigger OnRun()
    begin
        FindEntries('');
    end;

    local procedure FindEntries(SalesTicketNoFilter: text): Text
    var
        POSSaleEntryLine: Record "NPR POS Entry Sales Line";
        JArray: JsonArray;
    begin
        if SalesTicketNoFilter <> '' then
            POSSaleEntryLine.SetRange("Document No.", SalesTicketNoFilter);
        GetEntries(POSSaleEntryLine, JArray);
        exit(FormatResponese(JArray));
    end;

    local procedure GetEntries(var POSSaleEntryLine: Record "NPR POS Entry Sales Line"; JArray: JsonArray)
    var
        JObject: JsonObject;
        POSEntrySale: Record "NPR POS Entry";
    begin
        repeat
            Clear(JObject);
            if POSEntrySale.Get(POSSaleEntryLine."POS Entry No.") then begin
                JObject.Add('Register_No', POSEntrySale."POS Period Register No.");
                JObject.Add('Document_Date', POSEntrySale."Document Date");
            end;
            JObject.Add('Document_No', POSSaleEntryLine."Document No.");
            JObject.Add('Customer_No', POSSaleEntryLine."Customer No.");
            JObject.Add('No', POSSaleEntryLine."No.");
            JObject.Add('Variant_Code', POSSaleEntryLine."Variant Code");
            JObject.Add('Quantity', POSSaleEntryLine.Quantity);
            JObject.Add('Unit_Price', POSSaleEntryLine."Unit Price");
            JObject.Add('Discount', POSSaleEntryLine."Line Discount %");
            JObject.Add('Line_Amount', POSSaleEntryLine."Line Amount");
            JObject.Add('Description', POSSaleEntryLine.Description);
            JObject.Add('Description2', POSSaleEntryLine."Description 2");
            JArray.Add(JObject);
        until POSSaleEntryLine.Next() = 0;
    end;

    local procedure FormatResponese(JArray: JsonArray): Text
    var
        JArrayText: Text;
    begin
        JArray.WriteTo(JArrayText);
        exit(JArrayText);
    end;
}