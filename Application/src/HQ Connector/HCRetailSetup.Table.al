﻿table 6150904 "NPR HC Retail Setup"
{
    Access = Internal;
    Caption = 'HC Retail Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-07-28';
    ObsoleteReason = 'HQ Connector will no longer be supported';

    fields
    {
        field(1; "Key"; Code[20])
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
            Description = 'Primærn¢gle';
        }
        field(13; "Amount Rounding Precision"; Decimal)
        {
            Caption = 'Amount Rounding Precision';
            DataClassification = CustomerContent;
            Description = 'Afrundingspræcision for ¢reafrunding';
            InitValue = 0.25;
            MaxValue = 1;
            MinValue = 0;

            trigger OnValidate()
            var
                "Integer": Integer;
                t001: Label '%1';
            begin
                if "Amount Rounding Precision" <> 0 then
                    if not Evaluate(Integer, StrSubstNo(t001, 1 / "Amount Rounding Precision")) then
                        Error(Text1060006);
            end;
        }
        field(20; "Posting Source Code"; Code[10])
        {
            Caption = 'Posting Source Code';
            DataClassification = CustomerContent;
            Description = 'Kildespor til bogf¢ring';
            TableRelation = "Source Code";
        }
        field(51; "Posting No. Management"; Code[20])
        {
            Caption = 'Posting No. Management';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til kassebogf¢ring';
            TableRelation = "No. Series";
        }
        field(450; "Gen. Journal Template"; Code[10])
        {
            Caption = 'Gen. Journal Template';
            DataClassification = CustomerContent;
            Description = 'BC';
            TableRelation = "Gen. Journal Template";
        }
        field(451; "Gen. Journal Batch"; Code[10])
        {
            Caption = 'Gen. Journal Batch';
            DataClassification = CustomerContent;
            Description = 'BC';
            TableRelation = "Gen. Journal Batch".Name WHERE("Journal Template Name" = FIELD("Gen. Journal Template"));
        }
        field(455; "Item Journal Template"; Code[10])
        {
            Caption = 'Item Journal Template';
            DataClassification = CustomerContent;
            Description = 'BC';
            TableRelation = "Item Journal Template";
        }
        field(456; "Item Journal Batch"; Code[10])
        {
            Caption = 'Item Journal Batch';
            DataClassification = CustomerContent;
            Description = 'BC';
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FIELD("Item Journal Template"));
        }
        field(460; "Dimensions Posting Type"; Option)
        {
            Caption = 'Dimensions Posting Type';
            DataClassification = CustomerContent;
            Description = 'NPR5.48';
            OptionCaption = ' ,Delete,Recreate,Custom';
            OptionMembers = " ",Delete,Recreate,Custom;
        }
        field(700; "Selection No. Series"; Code[20])
        {
            Caption = 'Selection nos.';
            DataClassification = CustomerContent;
            Description = 'Nummerserie til udlejning';
            TableRelation = "No. Series";
        }
        field(800; "Balancing Posting Type"; Option)
        {
            Caption = 'Balancing';
            DataClassification = CustomerContent;
            Description = 'Opsætning til kasseafslutning';
            OptionCaption = 'PER REGISTER,TOTAL';
            OptionMembers = "PER KASSE",SAMLET;
        }
        field(4018; "Vat Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            Description = 'Værdi som automatisk sættes når man opretter en debitor.';
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(5092; "Post registers compressed"; Boolean)
        {
            Caption = 'Post registers compressed';
            DataClassification = CustomerContent;
        }
        field(5188; "Appendix no. eq Sales Ticket"; Boolean)
        {
            Caption = 'Appendix no. equals sales ticket no.';
            DataClassification = CustomerContent;
        }
        field(6176; "Compress G/L Entries"; Boolean)
        {
            Caption = 'Compress G/L Entries';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Key")
        {
        }
    }

    var
        Text1060006: Label 'Rounding precision must be divisible by 1. Example: 0,25 * 4 = 1';
}

