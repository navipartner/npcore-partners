﻿table 6014531 "NPR DE POS Audit Log Aux. Info"
{
    Access = Internal;
    Caption = 'DE POS Audit Log Aux. Info';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry No.";
        }
        field(10; "NPR Version"; Text[250])
        {
            Caption = 'NPR Version';
            DataClassification = CustomerContent;
        }
        field(20; "TSS Code"; Code[10])
        {
            Caption = 'TSS Code';
            TableRelation = "NPR DE TSS";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DETSS: Record "NPR DE TSS";
            begin
                if "TSS Code" = '' then
                    exit;
                DETSS.Get("TSS Code");
                "TSS ID" := DETSS.SystemId;
            end;
        }
        field(30; "TSS ID"; Guid)
        {
            Caption = 'TSS ID';
            DataClassification = CustomerContent;
        }
        field(40; "Client ID"; Guid)
        {
            Caption = 'Client ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                POSUnitAuxPar: Record "NPR DE POS Unit Aux. Info";
            begin
                if not POSUnitAuxPar.GetBySystemId("Client ID") then
                    Clear(POSUnitAuxPar);
                "Serial Number" := POSUnitAuxPar."Serial Number";
            end;
        }
        field(50; "Serial Number"; Text[250])
        {
            Caption = 'Serial Number';
            DataClassification = CustomerContent;
        }
        field(60; "Transaction ID"; Guid)
        {
            Caption = 'Transaction ID';
            DataClassification = CustomerContent;
        }
        field(70; "Start Time"; DateTime)
        {
            Caption = 'Start Time';
            DataClassification = CustomerContent;
        }
        field(80; "Finish Time"; DateTime)
        {
            Caption = 'Finish Time';
            DataClassification = CustomerContent;
        }
        field(90; "Time Format"; Text[250])
        {
            Caption = 'Time Format';
            DataClassification = CustomerContent;
        }
        field(100; Signature; Blob)
        {
            Caption = 'Signature';
            DataClassification = CustomerContent;
        }
        field(110; "Signature Count"; Integer)
        {
            Caption = 'Signature Count';
            DataClassification = CustomerContent;
        }
        field(120; "Signature Algorithm"; Text[250])
        {
            Caption = 'Signature Algorithm';
            DataClassification = CustomerContent;
        }
        field(130; "Public Key"; Blob)
        {
            Caption = 'Public Key';
            DataClassification = CustomerContent;
        }
        field(140; "QR Data"; Blob)
        {
            Caption = 'QR Data';
            DataClassification = CustomerContent;
        }
        field(145; "Fiskaly Transaction Type"; Enum "NPR DE Fiskaly Receipt Type")
        {
            Caption = 'Fiskaly Transaction Type';
            DataClassification = CustomerContent;
        }
        field(150; "Fiscalization Status"; Enum "NPR Fiscalization Status")
        {
            Caption = 'Fiscalization Status';
            DataClassification = CustomerContent;
        }
        field(155; "Fiskaly Transaction State"; Enum "NPR DE Fiskaly Trx. State")
        {
            Caption = 'Fiskaly Transaction State';
            DataClassification = CustomerContent;
        }
        field(160; "Last Revision"; Text[5])
        {
            Caption = 'Last Revision';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Incorrect data type. Replaced by integer field "Latest Revision"';
        }
        field(161; "Latest Revision"; Integer)
        {
            Caption = 'Latest Revision';
            DataClassification = CustomerContent;
        }
        field(170; "Error Message"; Blob)
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(180; "Error"; Boolean)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Wrong field name.';
            Caption = 'Error';
            DataClassification = CustomerContent;
        }
        field(190; "Has Error"; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "POS Entry No.")
        {
        }
        key(Key2; "Fiscalization Status")
        {
        }
    }
}
