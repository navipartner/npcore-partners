table 6059853 "NPR Digital Receipt Setup"
{
    Access = Internal;
    Caption = 'Digital Receipt Setup';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Api Key"; Text[250])
        {
            Caption = 'Api Key';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ChangeCredentialsAllowed();
            end;
        }
        field(20; "Api Secret"; Text[250])
        {
            Caption = 'Api Secret';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ChangeCredentialsAllowed();
            end;
        }
        field(30; "Credentials Test Success"; Boolean)
        {
            Caption = 'Credentials Test Success';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "Last Credentials Test DateTime"; DateTime)
        {
            Caption = 'Last Credential Test Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "Bearer Token Value"; Text[2048])
        {
            Caption = 'Bearer Token Value';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Bearer Token Expires At"; DateTime)
        {
            Caption = 'Bearer Token Expires At';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }


    local procedure ChangeCredentialsAllowed()
    var
        POSReceiptProfiles: Record "NPR POS Receipt Profile";
        ChangeNotAllowedErr: Label 'You cannot change this field, digital receipt is enabled on: POS Receipt Profile: %1';
    begin
        POSReceiptProfiles.SetRange("Enable Digital Receipt", true);
        if POSReceiptProfiles.FindFirst() then
            Error(Format(StrSubstNo(ChangeNotAllowedErr, POSReceiptProfiles.Code)));
        Rec."Credentials Test Success" := false;
        Clear(Rec."Bearer Token Value");
        Clear(Rec."Bearer Token Expires At");
        Clear(Rec."Last Credentials Test DateTime");
    end;
}
