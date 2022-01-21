table 6014622 "NPR EFT Recon. Provider"
{
    Caption = 'EFT Recon. Provider';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR EFT Recon. Provider List";
    LookupPageID = "NPR EFT Recon. Provider List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; Posting; Option)
        {
            Caption = 'Posting';
            DataClassification = CustomerContent;
            OptionCaption = 'Through Journal,Direct';
            OptionMembers = "Through Journal",Direct;
        }
        field(110; "Bank Account"; Code[20])
        {
            Caption = 'Bank Account';
            DataClassification = CustomerContent;
            TableRelation = "Bank Account";
        }
        field(120; "Transaktion Account"; Code[20])
        {
            Caption = 'Transaktion Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(130; "Fee Account"; Code[20])
        {
            Caption = 'Fee Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(140; "Subscription Account"; Code[20])
        {
            Caption = 'Subscription Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(150; "Chargeback Account"; Code[20])
        {
            Caption = 'Chargeback Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(160; "Adjustment Account"; Code[20])
        {
            Caption = 'Adjustment Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(200; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template";
        }
        field(210; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(220; "No. Series"; Code[10])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(230; "Posting Description"; Text[50])
        {
            Caption = 'Posting Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

