table 6150775 "NPR IT Aux Customer"
{
    Access = Internal;
    Caption = 'IT Aux Customer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Salesperson/Purchaser SystemId';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(2; "NPR IT Customer Lottery Code"; Text[15])
        {
            Caption = 'IT Customer Lottery Code';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CheckLotteryCodeValidity();
            end;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    internal procedure ReadITAuxCustomerFields(Customer: Record "Customer")
    var
        ITAuditMgt: Codeunit "NPR IT Audit Mgt.";
    begin
        if not ITAuditMgt.IsITFiscalEnabled() then
            exit;
        if not Rec.Get(Customer."No.") then begin
            Rec.Init();
            Rec."No." := Customer."No.";
        end;
    end;

    internal procedure SaveITAuxCustomerFields()
    begin
        if not Insert() then
            Modify();
    end;

    local procedure CheckLotteryCodeValidity()
    begin
        CheckLotteryCodeLength();
        CheckForSpecialCharacters();
    end;

    local procedure CheckLotteryCodeLength()
    var
        LotteryCodeLengthErr: Label 'Lottery Code must be minimum 2 characters in length and a maximum of 16.';
    begin
        if not (StrLen(Format("NPR IT Customer Lottery Code")) in [2 .. 15]) then
            Error(LotteryCodeLengthErr);
    end;

    local procedure CheckForSpecialCharacters()
    var
        LotteryCodeMustNotContainSpecialCharsErr: Label 'Lottery Code must not contain any special characters. It can only consist of alphanumerical values. (A-Z, a-z, 0-9).';
        AllowedChars: Label 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    begin
        if (DelChr(Rec."NPR IT Customer Lottery Code", '=', AllowedChars) <> '') then
            Error(LotteryCodeMustNotContainSpecialCharsErr);
    end;

}