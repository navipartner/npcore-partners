﻿table 6014584 "NPR Replication Error Log"
{
    Access = Internal;
    Caption = 'Replication Error Log';
    DataClassification = CustomerContent;
    Extensible = false;
    LookupPageId = "NPR Replication Error Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "API Version"; Code[20])
        {
            Caption = 'API Version';
            DataClassification = CustomerContent;
        }
        field(15; "Endpoint ID"; Text[50])
        {
            Caption = 'Endpoint ID';
            DataClassification = CustomerContent;
        }
        field(20; URL; Text[250])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
        }
        field(21; Method; Code[10])
        {
            Caption = 'Method';
            DataClassification = CustomerContent;
        }
        field(30; Request; Blob)
        {
            Caption = 'Request';
            DataClassification = CustomerContent;
        }
        field(31; Response; Blob)
        {
            Caption = 'Response';
            DataClassification = CustomerContent;
        }
        field(41; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }

        field(50; "Email Notification Sent"; Boolean)
        {
            Caption = 'Email Notification Sent';
            DataClassification = EndUserIdentifiableInformation;
        }

    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    procedure InsertLog(pAPIVersion: Code[20]; pURL: Text; pResponseTxt: text; RecipientEmail: Text[100])
    begin
        InsertLog(pAPIVersion, '', '', pURL, '', pResponseTxt, RecipientEmail);
    end;

    procedure InsertLog(pAPIVersion: Code[20]; pEndpointID: Text[50]; pURL: Text; pResponseTxt: text; RecipientEmail: Text[100])
    begin
        InsertLog(pAPIVersion, pEndpointID, '', pURL, '', pResponseTxt, RecipientEmail);
    end;

    procedure InsertLog(pAPIVersion: Code[20]; pEndpointID: Text[50]; pMethod: Code[10]; pURL: Text; pResponse: Codeunit "Temp Blob"; RecipientEmail: Text[100])
    var
        InStr: instream;
        ResponseTxt: Text;
    begin
        pResponse.CreateInStream(InStr);
        InStr.Read(ResponseTxt, MaxStrLen(ResponseTxt));
        InsertLog(pAPIVersion, pEndpointID, pMethod, pURL, '', ResponseTxt, RecipientEmail);
    end;

    procedure InsertLog(pAPIVersion: Code[20]; pEndpointID: Text[50]; pMethod: Code[10]; pURL: Text; pRequest: Text; pResponse: text; RecipientEmail: Text[100])
    var
        LastErrorLog: Record "NPR Replication Error Log";
        oStr: OutStream;
    begin
        Rec.Init();
        Rec."Entry No." := 1;
        IF LastErrorLog.FindLast() then
            Rec."Entry No." += LastErrorLog."Entry No.";
        Rec."API Version" := pAPIVersion;
        Rec."Endpoint ID" := pEndpointID;
        Rec.Method := pMethod;
        Rec.URL := copyStr(pURL, 1, 250);
        Rec."User ID" := CopyStr(UserId, 1, MaxStrLen(Rec."User ID"));
        Rec.Insert(true);
        Rec.Request.CreateOutStream(oStr);
        oStr.WriteText(pRequest);
        Rec.Response.CreateOutStream(Ostr);
        oStr.WriteText(pResponse);

        if SendErrorViaEmail(RecipientEmail) then
            Rec."Email Notification Sent" := true;

        Rec.Modify();
    end;

    local procedure SendErrorViaEmail(RecipientEmail: Text[100]): Boolean
    var
        EMailMgt: Codeunit "NPR E-mail Management";
        RecRef: RecordRef;
    begin
        if RecipientEmail <> '' then begin
            RecRef.GetTable(Rec);
            exit(EMailMgt.SendEmail(RecRef, RecipientEmail, true) = '');
        end;
        exit(false);
    end;

    procedure ReadTextFromBlob(FieldNo: Integer): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        Instr: Instream;
        TempBlobBuffer: Record "NPR BLOB buffer" temporary;
        ReadTxt: text;
    begin
        RecRef.GetTable(Rec);
        FldRef := RecRef.Field(FieldNo);
        FldRef.CalcField();
        TempBlobBuffer.Init();
        TempBlobBuffer."Buffer 1" := FldRef.Value;
        IF NOT TempBlobBuffer."Buffer 1".Hasvalue then
            Exit('');

        TempBlobBuffer."Buffer 1".CreateInStream(Instr);
        Instr.Read(ReadTxt, MaxStrLen(ReadTxt));
        exit(ReadTxt);
    end;
}
