table 6150805 "NPR Adyen Webhook Setup"
{
    Access = Internal;

    Caption = 'Adyen Webhook Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
            AutoIncrement = true;
        }
        field(10; ID; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
        }
        field(20; Type; Enum "NPR Adyen Webhook Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
        }
        field(30; "Web Service URL"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Web Service URL';

            trigger OnValidate()
            begin
                if not ("Web Service URL".Contains('https://') or "Web Service URL".Contains('http://')) then begin
                    "Web Service URL" := CopyStr('https://' + "Web Service URL", 1, MaxStrLen("Web Service URL"));
                end
            end;
        }
        field(40; "Web Service Security"; Enum "NPR Adyen WWS Security Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Web Service Security';
            InitValue = " ";
        }
        field(50; "Web Service User"; Text[256])
        {
            DataClassification = CustomerContent;
            Caption = 'Web Service User';
        }
        field(60; "Web Service Password"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Web Service Password';
        }
        field(70; Active; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Active';
        }
        field(80; "Merchant Accounts Filter Type"; Enum "NPR Adyen Merchant Filter Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Accounts Filter Type';
        }
        field(90; "Merchant Accounts Filter"; Text[2048])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Accounts Filter';
        }
        field(100; Description; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        ModifyError: Label 'Something went wrong!';
    begin
        if (ID <> '') and ((("Web Service User" <> '') and ("Web Service Password" <> '')) or (("Web Service User" = '') and ("Web Service Password" = ''))) then
            if not AdyenManagement.ModifyWebhook(Rec) then
                Error(ModifyError);
    end;

    trigger OnDelete()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        ConfirmDelete: Label 'Would you like to delete this webhook from Adyen as well?';
    begin
        if ID <> '' then
            if Confirm(ConfirmDelete) then begin
                AdyenManagement.DeleteWebhook(Rec);
            end;
    end;
}
