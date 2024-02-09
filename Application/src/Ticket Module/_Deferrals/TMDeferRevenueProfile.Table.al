table 6150778 "NPR TM DeferRevenueProfile"
{
    DataClassification = CustomerContent;
    Access = Internal;
    Caption = ' Ticketing Defer Revenue Profile';
    fields
    {
        field(1; DeferRevenueProfileCode; Code[10])
        {
            DataClassification = CustomerContent;

        }
        field(10; AchievedRevenueAccount; Code[20])
        {
            Caption = 'Achieved Revenue Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(20; InterimAdjustmentAccount; Code[20])
        {
            Caption = 'Interim Adjustment Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(30; NoSeries; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(40; JournalTemplateName; Code[10])
        {
            Caption = 'Journal Template Name';
            TableRelation = "Gen. Journal Template";
            Description = 'Initially created for BE localization';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GenJournalTemplate: Record "Gen. Journal Template";
            begin
                if (not GenJournalTemplate.Get(Rec.JournalTemplateName)) then
                    GenJournalTemplate.Init();
                Rec.SourceCode := GenJournalTemplate."Source Code";
            end;
        }
        field(50; SourceCode; Code[10])
        {
            Caption = 'Source Code';
            DataClassification = CustomerContent;
            TableRelation = "Source Code";
        }
        field(60; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(70; ReversalReasonCode; Code[10])
        {
            Caption = 'Reversal Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(71; ReversalPostingDescription; Text[50])
        {
            Caption = 'Reversal Posting Description';
            DataClassification = CustomerContent;
            InitValue = 'Ticket Deferral: Reversed Revenue';
        }
        field(75; DeferralReasonCode; Code[10])
        {
            Caption = 'Deferral Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(76; DeferralPostingDescription; Text[50])
        {
            Caption = 'Deferral Posting Description';
            DataClassification = CustomerContent;
            InitValue = 'Ticket Deferral: Achieved Revenue';
        }
        field(80; PostingMode; Option)
        {
            Caption = 'Posting Mode';
            DataClassification = CustomerContent;
            OptionMembers = COMPRESSED,UNCOMPRESSED,INLINE;
            OptionCaption = 'Compressed,Uncompressed,Inline';
        }
        field(90; MaxAttempts; Integer)
        {
            Caption = 'Max Attempts';
            DataClassification = CustomerContent;
            InitValue = 30;
        }
    }

    keys
    {
        key(Key1; DeferRevenueProfileCode)
        {
            Clustered = true;
        }
    }

}