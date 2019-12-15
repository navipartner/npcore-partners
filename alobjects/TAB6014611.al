table 6014611 "Retail Campaign Line"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign

    Caption = 'Retail Campaign Line';

    fields
    {
        field(1;"Campaign Code";Code[20])
        {
            Caption = 'Campaign Code';
            TableRelation = "Retail Campaign Header";
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;Type;Option)
        {
            Caption = 'Discount Type';
            InitValue = "Period Discount";
            OptionCaption = ',Period Discount,Mixed Discount';
            OptionMembers = " ","Period Discount","Mixed Discount";
        }
        field(15;"Code";Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type=CONST("Period Discount")) "Period Discount"
                            ELSE IF (Type=CONST("Mixed Discount")) "Mixed Discount";

            trigger OnValidate()
            var
                MixedDiscount: Record "Mixed Discount";
                PeriodDiscount: Record "Period Discount";
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
        field(20;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Campaign Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;
}

