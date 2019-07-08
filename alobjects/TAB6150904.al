table 6150904 "HC Retail Setup"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector: Created object based on Table 6014400
    // NPR5.48/TJ  /20181114 CASE 331992 New field "Dimensions Posting Type"

    Caption = 'HC Retail Setup';

    fields
    {
        field(1;"Key";Code[20])
        {
            Caption = 'Key';
            Description = 'Prim�rn�gle';
        }
        field(13;"Amount Rounding Precision";Decimal)
        {
            Caption = 'Amount Rounding Precision';
            Description = 'Afrundingspr�cision for �reafrunding';
            InitValue = 0.25;
            MaxValue = 1;
            MinValue = 0;

            trigger OnValidate()
            var
                "Integer": Integer;
                t001: Label '%1';
            begin
                if "Amount Rounding Precision" <> 0 then
                  if not Evaluate(Integer,StrSubstNo(t001,1/"Amount Rounding Precision")) then
                    Error(Text1060006+
                          Text1060007);
            end;
        }
        field(20;"Posting Source Code";Code[10])
        {
            Caption = 'Posting Source Code';
            Description = 'Kildespor til bogf�ring';
            TableRelation = "Source Code";
        }
        field(51;"Posting No. Management";Code[10])
        {
            Caption = 'Posting No. Management';
            Description = 'Nummerserie til kassebogf�ring';
            TableRelation = "No. Series";
        }
        field(450;"Gen. Journal Template";Code[10])
        {
            Caption = 'Gen. Journal Template';
            Description = 'BC';
            TableRelation = "Gen. Journal Template";
        }
        field(451;"Gen. Journal Batch";Code[10])
        {
            Caption = 'Gen. Journal Batch';
            Description = 'BC';
            TableRelation = "Gen. Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Gen. Journal Template"));
        }
        field(455;"Item Journal Template";Code[10])
        {
            Caption = 'Item Journal Template';
            Description = 'BC';
            TableRelation = "Item Journal Template";
        }
        field(456;"Item Journal Batch";Code[10])
        {
            Caption = 'Item Journal Batch';
            Description = 'BC';
            TableRelation = "Item Journal Batch".Name WHERE ("Journal Template Name"=FIELD("Item Journal Template"));
        }
        field(460;"Dimensions Posting Type";Option)
        {
            Caption = 'Dimensions Posting Type';
            Description = 'NPR5.48';
            OptionCaption = ' ,Delete,Recreate,Custom';
            OptionMembers = " ",Delete,Recreate,Custom;
        }
        field(700;"Selection No. Series";Code[10])
        {
            Caption = 'Selection nos.';
            Description = 'Nummerserie til udlejning';
            TableRelation = "No. Series";
        }
        field(800;"Balancing Posting Type";Option)
        {
            Caption = 'Balancing';
            Description = 'Ops�tning til kasseafslutning';
            OptionCaption = 'PER REGISTER,TOTAL';
            OptionMembers = "PER KASSE",SAMLET;
        }
        field(4018;"Vat Bus. Posting Group";Code[10])
        {
            Caption = 'VAT Bus. Posting Group';
            Description = 'V�rdi som automatisk s�ttes n�r man opretter en debitor.';
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(5092;"Post registers compressed";Boolean)
        {
            Caption = 'Post registers compressed';
        }
        field(5188;"Appendix no. eq Sales Ticket";Boolean)
        {
            Caption = 'Appendix no. equals sales ticket no.';
        }
        field(6176;"Compress G/L Entries";Boolean)
        {
            Caption = 'Compress G/L Entries';
        }
    }

    keys
    {
        key(Key1;"Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text1060006: Label 'Rounding precision must be divisible by 1.';
        Text1060007: Label 'Example: 0,25 * 4 = 1';
        Text1060008: Label 'No. Series cannot be changed!';
        Text1060009: Label 'The field cannot be modified when there is payment choise.';
        Text1060017: Label 'Due to missing index, this option can delay the sales. Accept?';
        Text1060018: Label 'Teh update was cancelled by the user.';
}

