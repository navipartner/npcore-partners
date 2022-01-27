table 6014534 "NPR VAT Prod Post Group Mapper"
{
    Access = Internal;
    Caption = 'VAT Product Posting Group Mapper';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Primary Key change';

    fields
    {
        field(1; "VAT Prod. Pos. Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                VATPostingSetupPage: Page "VAT Posting Setup";
                VATPostingSetupRec: Record "VAT Posting Setup";
            begin
                VATPostingSetupPage.LOOKUPMODE(TRUE);
                VATPostingSetupPage.SETRECORD(VATPostingSetupRec);
                IF VATPostingSetupPage.RUNMODAL() = ACTION::LookupOK THEN BEGIN
                    VATPostingSetupPage.GETRECORD(VATPostingSetupRec);
                    Rec."VAT Prod. Pos. Group" := VATPostingSetupRec."VAT Prod. Posting Group";
                    Rec."VAT Bus. Posting Group" := VATPostingSetupRec."VAT Bus. Posting Group";
                    Rec."VAT Identifier" := VATPostingSetupRec."VAT Identifier";
                END;
            end;
        }
        field(2; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
        }
        field(3; "VAT Identifier"; Code[20])
        {
            Caption = 'VAT Identifier';
            DataClassification = CustomerContent;
        }
        field(10; "Fiscal Name"; Code[50])
        {
            Caption = 'Fiscal Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "VAT Prod. Pos. Group")
        {
            Clustered = true;
        }
    }
}
