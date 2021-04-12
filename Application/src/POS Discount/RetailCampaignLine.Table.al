table 6014611 "NPR Retail Campaign Line"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign

    Caption = 'Retail Campaign Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Campaign Code"; Code[20])
        {
            Caption = 'Campaign Code';
            TableRelation = "NPR Retail Campaign Header";
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Discount Type';
            InitValue = "Period Discount";
            OptionCaption = ',Period Discount,Mixed Discount';
            OptionMembers = " ","Period Discount","Mixed Discount";
            DataClassification = CustomerContent;
        }
        field(15; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST("Period Discount")) "NPR Period Discount"
            ELSE
            IF (Type = CONST("Mixed Discount")) "NPR Mixed Discount";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MixedDiscount: Record "NPR Mixed Discount";
                PeriodDiscount: Record "NPR Period Discount";
            begin
                if Code = '' then begin
                    Description := '';
                    exit;
                end;

                case Type of
                    Type::"Period Discount":
                        begin
                            PeriodDiscount.Get(Code);
                            Description := PeriodDiscount.Description;
                        end;
                    Type::"Mixed Discount":
                        begin
                            MixedDiscount.Get(Code);
                            Description := MixedDiscount.Description;
                        end;
                end;
            end;
        }
        field(20; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Campaign Code", "Line No.")
        {
        }
    }

    fieldgroups
    {
    }

}

