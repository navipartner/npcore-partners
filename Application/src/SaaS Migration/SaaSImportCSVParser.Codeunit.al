codeunit 6151093 "NPR SaaS Import CSV Parser"
{
    Access = Internal;
    TableNo = "NPR Saas Import Chunk";
    Permissions = TableData "G/L Account" = rimd,
                  TableData "G/L Entry" = rimd,
                  TableData "Cust. Ledger Entry" = rimd,
                  tabledata "Customer Posting Group" = rimd,
                  TableData "Vendor Ledger Entry" = rimd,
                  tabledata "Vendor Posting Group" = rimd,
                  TableData "G/L Register" = rimd,
                  TableData "G/L Entry - VAT Entry Link" = rimd,
                  TableData "VAT Entry" = rimd,
                  TableData "Bank Account Ledger Entry" = rimd,
                  TableData "Check Ledger Entry" = rimd,
                  TableData "Detailed Cust. Ledg. Entry" = rimd,
                  TableData "Detailed Vendor Ledg. Entry" = rimd,
                  TableData "Line Fee Note on Report Hist." = rim,
                  TableData "Employee Ledger Entry" = rimd,
                  TableData "Detailed Employee Ledger Entry" = rimd,
                  tabledata "Source Code Setup" = rimd,
                  tabledata "Sales & Receivables Setup" = rimd,
                  tabledata "Purchases & Payables Setup" = rimd,
                  TableData "FA Ledger Entry" = rimd,
                  TableData "FA Register" = rimd,
                  TableData "Sales Line" = rimd,
                  TableData "Purchase Header" = rimd,
                  TableData "Purchase Line" = rimd,
                  TableData "Sales Shipment Header" = rimd,
                  TableData "Sales Shipment Line" = rimd,
                  TableData "Sales Invoice Header" = rimd,
                  TableData "Sales Invoice Line" = rimd,
                  TableData "Sales Cr.Memo Header" = rimd,
                  TableData "Sales Cr.Memo Line" = rimd,
                  TableData "Purch. Rcpt. Header" = rimd,
                  TableData "Purch. Rcpt. Line" = rimd,
                  TableData "Purch. Inv. Header" = rimd,
                  TableData "Purch. Inv. Line" = rimd,
                  TableData "Purch. Cr. Memo Hdr." = rimd,
                  TableData "Purch. Cr. Memo Line" = rimd,
                  TableData "Drop Shpt. Post. Buffer" = rimd,
                  TableData "General Posting Setup" = rimd,
                  TableData "Posted Assemble-to-Order Link" = rimd,
                  TableData "Service Item" = rimd,
                  TableData "Value Entry" = rimd,
                  TableData "Item Entry Relation" = rimd,
                  TableData "Value Entry Relation" = rimd,
                  TableData "Return Receipt Header" = rimd,
                  TableData "Return Receipt Line" = rimd,
                  TableData "Return Shipment Header" = rimd,
                  TableData "Return Shipment Line" = rimd,
                  TableData "Item Ledger Entry" = rimd,
                  TableData "G/L - Item Ledger Relation" = rimd,
                  TableData "Maintenance Ledger Entry" = rimd,
                  TableData "Phys. Inventory Ledger Entry" = rimd,
                  TableData "Dimension Set Entry" = rimd,
                  TableData "Dimension Set Tree Node" = rimd,
                  TableData "Tenant Media Thumbnails" = rimd,
                  TableData "Tenant Media" = rimd,
                  TableData "Item Application Entry" = rimd,
                  TableData "Item Register" = rimd,
                  TableData "Batch Processing Parameter" = rimd,
                  TableData "Approval Entry" = rimd,
                  TableData "Posted Approval Entry" = rimd,
                  TableData "Posted Approval Comment Line" = rimd,
                  TableData "Workflow Step Instance Archive" = rimd,
                  TableData "Workflow Step Argument Archive" = rimd;


    trigger OnRun()
    var
        IStream: InStream;
        DataLogManagement: Codeunit "NPR Data Log Management";
    begin
        LockTimeout(false);
        DataLogManagement.DisableDataLog(true);

        Rec.Chunk.CreateInStream(IStream, TextEncoding::UTF8);
        Import(IStream);
    end;

    procedure Import(var IStream: InStream)
    var
        RecRef: RecordRef;
        FieldReference: FieldRef;
        TableId: Integer;
        Line: Text;
        TextField: Text;
        TextList: List of [Text];
        FieldList: List of [Integer];
        IntBuffer: Integer;
        i: Integer;
        FormattedValue: Text;
    begin
        IStream.ReadText(Line);
        Evaluate(TableId, Line);

        IStream.ReadText(Line);
        TextList := Line.Split('|');
        foreach TextField in TextList do begin
            Evaluate(IntBuffer, TextField);
            FieldList.Add(IntBuffer);
        end;

        RecRef.Open(TableId);

        while (not IStream.EOS) do begin
            IStream.ReadText(Line);
            //Remove starting and ending " and split 
            TextList := Line.Substring(2, StrLen(Line) - 2).Split('"|"');

            RecRef.Init();
            i := 0;
            foreach FormattedValue in TextList do begin
                i += 1;
                FieldReference := RecRef.Field(FieldList.Get(i));
                //De-escape after our split
                FormattedValueToFieldRef(FormattedValue.Replace('\|', '|').Replace('\"', '"'), FieldReference);
            end;
            if not RecRef.Insert(false, true) then
                RecRef.Modify();
        end;

        RecRef.Close();
    end;

    local procedure FormattedValueToFieldRef(FormattedValue: Text; var FieldReference: FieldRef)
    var
        TempBlob: Codeunit "Temp Blob";
        Base64Convert: Codeunit "Base64 Convert";
        OutStr: OutStream;
        ValueDate: Date;
        ValueTime: Time;
        ValueDateTime: DateTime;
        ValueDateFormula: DateFormula;
        ValueDuration: Duration;
        ValueGUID: Guid;
        ValueRecordID: RecordID;
        ValueBigInt: BigInteger;
        ValueDecimal: Decimal;
        ValueInt: Integer;
        ValueBool: Boolean;
        IStream: InStream;
        MediaId: Guid;
        TextValue: Text;
        ClosingDateVar: Date;
        SaaSImportMediaBuffer: Record "NPR SaaS Import Media Buffer";
    begin
        case FieldReference.Type of
            FieldType::Text,
            FieldType::Code:
                FieldReference.Value := FormattedValue;
            FieldType::Integer,
            FieldType::Option:
                begin
                    Evaluate(ValueInt, FormattedValue, 9);
                    FieldReference.Value := ValueInt;
                end;
            FieldType::Boolean:
                begin
                    Evaluate(ValueBool, FormattedValue, 9);
                    FieldReference.Value := ValueBool;
                end;
            FieldType::Blob:
                begin
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FormattedValue, OutStr);
                    TempBlob.ToFieldRef(FieldReference);
                end;
            FieldType::Media:
                begin
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FormattedValue, OutStr);
                    TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

                    SaaSImportMediaBuffer.Init();
                    MediaId := SaaSImportMediaBuffer."Media Buffer".ImportStream(IStream, 'Auto imported media via saas data migration tool');
                    FieldReference.Value := MediaId;
                end;
            FieldType::MediaSet:
                begin
                    TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FormattedValue, OutStr);
                    TempBlob.CreateInStream(IStream, TextEncoding::UTF8);

                    SaaSImportMediaBuffer.Init();
                    MediaId := SaaSImportMediaBuffer."Media Set Buffer".ImportStream(IStream, 'Auto imported mediaset via saas data migration tool');
                    FieldReference.Value := MediaId;
                end;
            FieldType::Decimal:
                begin
                    Evaluate(ValueDecimal, FormattedValue, 9);
                    FieldReference.Value := ValueDecimal;
                end;
            FieldType::BigInteger:
                begin
                    Evaluate(ValueBigInt, FormattedValue, 9);
                    FieldReference.Value := ValueBigInt;
                end;
            FieldType::Date:
                begin
                    if FormattedValue[1] = 'C' then begin
                        TextValue := FormattedValue.TrimStart('C');
                        Evaluate(ClosingDateVar, TextValue, 9);
                        FieldReference.Value := ClosingDate(ClosingDateVar);
                    end else begin
                        Evaluate(ValueDate, FormattedValue, 9);
                        FieldReference.Value := ValueDate;
                    end;
                end;
            FieldType::DateTime:
                begin
                    Evaluate(ValueDateTime, FormattedValue, 9);
                    FieldReference.Value := ValueDateTime;
                end;
            FieldType::Time:
                begin
                    Evaluate(ValueTime, FormattedValue, 9);
                    FieldReference.Value := ValueTime;
                end;
            FieldType::DateFormula:
                begin
                    Evaluate(ValueDateFormula, FormattedValue, 9);
                    FieldReference.Value := ValueDateFormula;
                end;
            FieldType::Duration:
                begin
                    Evaluate(ValueDuration, FormattedValue, 9);
                    FieldReference.Value := ValueDuration;
                end;
            FieldType::Guid:
                begin
                    Evaluate(ValueGUID, FormattedValue, 9);
                    FieldReference.Value := ValueGUID;
                end;
            FieldType::RecordId:
                begin
                    if not Evaluate(ValueRecordID, FormattedValue, 9) then
                        Evaluate(ValueRecordID, 'NPR ' + FormattedValue, 9);
                    FieldReference.Value := ValueRecordID;
                end;
            else
                Error('Unsupported type %1 on field %2', Format(FieldReference.Type), FieldReference.Number);
        end;
    end;
}