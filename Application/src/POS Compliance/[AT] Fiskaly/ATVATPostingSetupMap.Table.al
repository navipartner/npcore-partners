table 6150855 "NPR AT VAT Posting Setup Map"
{
    Access = Internal;
    Caption = 'AT VAT Posting Setup Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT VAT Posting Setup Map";
    LookupPageId = "NPR AT VAT Posting Setup Map";

    fields
    {
        field(1; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";

            trigger OnValidate()
            begin
                if "VAT Bus. Posting Group" <> xRec."VAT Bus. Posting Group" then
                    SetVATIdentifier();
            end;
        }
        field(2; "VAT Prod. Posting Group"; Code[20])
        {
            Caption = 'VAT Prod. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";

            trigger OnValidate()
            begin
                if "VAT Prod. Posting Group" <> xRec."VAT Prod. Posting Group" then
                    SetVATIdentifier();
            end;
        }
        field(20; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
        }
        field(30; "AT VAT Rate"; Enum "NPR AT VAT Rate")
        {
            Caption = 'AT VAT Rate';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "VAT Bus. Posting Group", "VAT Prod. Posting Group")
        {
        }
    }

    local procedure SetVATIdentifier()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        Clear("VAT Identifier");
        if VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
            "VAT Identifier" := VATPostingSetup."VAT Identifier";
    end;

    internal procedure CheckIsATVATRatePopulated()
    var
        NotPopulatedErr: Label '%1 must be populated for %2 %3 VAT Posting Setup.', Comment = '%1 - AT VAT Rate field caption, %2 - VAT Bus. Posting Group field caption, %3 - VAT Prod. Posting Group field caption';
    begin
        if "AT VAT Rate" = "AT VAT Rate"::" " then
            Error(NotPopulatedErr, FieldCaption("AT VAT Rate"), "VAT Bus. Posting Group", "VAT Prod. Posting Group");
    end;
}