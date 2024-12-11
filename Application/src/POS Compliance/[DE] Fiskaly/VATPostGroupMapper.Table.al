﻿table 6014578 "NPR VAT Post. Group Mapper"
{
    Access = Internal;
    Caption = 'VAT Posting Setup Mapper';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "VAT Prod. Pos. Group"; Code[20])
        {
            Caption = 'VAT Product Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group";

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
            TableRelation = "VAT Business Posting Group";
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
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by field 11 "Fiskaly VAT Rate Type"';
        }
        field(11; "Fiskaly VAT Rate Type"; Enum "NPR DE Fiskaly VAT Rate")
        {
            Caption = 'Fiskaly VAT Rate Type';
            DataClassification = CustomerContent;
        }
        field(20; "DSFINVK ID"; Integer)
        {
            Caption = 'DSFINVK ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "VAT Prod. Pos. Group", "VAT Bus. Posting Group")
        {
            Clustered = true;
        }
    }
}
