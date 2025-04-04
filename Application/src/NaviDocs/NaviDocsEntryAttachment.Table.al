﻿table 6059944 "NPR NaviDocs Entry Attachment"
{
    Access = Internal;
    Caption = 'NaviDocs Entry Attachment';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "NaviDocs Entry No."; BigInteger)
        {
            Caption = 'NaviDocs Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Data; Blob)
        {
            Caption = 'Data';
            DataClassification = CustomerContent;
        }
        field(20; "File Extension"; Text[10])
        {
            Caption = 'File Extension';
            DataClassification = CustomerContent;
        }
        field(30; "Data Type"; Code[20])
        {
            Caption = 'Data Type';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Internal Type"; Enum "NPR ND Entry Att. Int. Type")
        {
            Caption = 'Internal Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "NaviDocs Entry No.", "Line No.")
        {
        }
    }

    var
        NoDataText: Label 'No Data in record.';

    procedure ShowOutput()
    var
        FileMgt: Codeunit "File Management";
        IsHandled: Boolean;
        TempBlob: Codeunit "Temp Blob";
    begin
        OnShowOutput(Rec, IsHandled);
        if IsHandled then
            exit;

        CalcFields(Data);
        if not Data.HasValue() then begin
            Message(NoDataText);
            exit;
        end;
        TempBlob.FromRecord(Rec, FieldNo(Data));
        FileMgt.BLOBExport(TempBlob, StrSubstNo(FilenamePattern(), "NaviDocs Entry No.", "File Extension"), true);
        exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShowOutput(var NaviDocsEntryAttachment: Record "NPR NaviDocs Entry Attachment"; var IsHandled: Boolean)
    begin
    end;

    local procedure FilenamePattern(): Text
    begin
        exit('NaviDocs-%1.%2');
    end;
}

