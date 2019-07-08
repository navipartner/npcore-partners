table 6060142 "MM Loyalty Item Point Setup"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System

    Caption = 'Loyalty Item Point Setup';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            TableRelation = "MM Loyalty Setup";
        }
        field(2;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(5;Blocked;Boolean)
        {
            Caption = 'Blocked';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Item Group,Item,Vendor';
            OptionMembers = "Item Group",Item,Vendor;
        }
        field(11;"No.";Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type=CONST("Item Group")) "Item Group"
                            ELSE IF (Type=CONST(Item)) Item
                            ELSE IF (Type=CONST(Vendor)) Vendor;

            trigger OnValidate()
            var
                Item: Record Item;
                ItemGroup: Record "Item Group";
                Vendor: Record Vendor;
            begin
                case Type of
                  Type::Item : if (Item.Get ("No.")) then Description := Item.Description;
                  Type::"Item Group" : if (ItemGroup.Get ("No.")) then Description := ItemGroup.Description;
                  Type::Vendor : if (Vendor.Get ("No.")) then Description := Vendor.Name;
                end;
            end;
        }
        field(12;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(15;Description;Text[80])
        {
            Caption = 'Description';
        }
        field(20;Constraint;Option)
        {
            Caption = 'Constraint';
            OptionCaption = 'Include,Exclude';
            OptionMembers = INCLUDE,EXCLUDE;

            trigger OnValidate()
            begin
                if (Constraint = Constraint::EXCLUDE) then begin
                  Award := Award::NA;
                  Points := 0;
                  "Amount Factor" := 0;
                end else begin
                  Award := Award::AMOUNT;
                  "Amount Factor" := 1;
                end;
            end;
        }
        field(21;"Allow On Discounted Sale";Boolean)
        {
            Caption = 'Allow On Discounted Sale';
        }
        field(25;"Valid From Date";Date)
        {
            Caption = 'Valid From Date';
        }
        field(26;"Valid Until Date";Date)
        {
            Caption = 'Valid Until Date';
        }
        field(30;Award;Option)
        {
            Caption = 'Award';
            InitValue = AMOUNT;
            OptionCaption = ' ,Points,Amount,Points+Amount';
            OptionMembers = NA,POINTS,AMOUNT,POINTS_AND_AMOUNT;
        }
        field(31;Points;Integer)
        {
            Caption = 'Points';
        }
        field(32;"Amount Factor";Decimal)
        {
            Caption = 'Amount Factor';
            InitValue = 1;
        }
    }

    keys
    {
        key(Key1;"Code","Line No.")
        {
        }
        key(Key2;Type,"No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        LoyaltyItemPointSetup: Record "MM Loyalty Item Point Setup";
    begin

        if ("Line No." = 0) then begin
          "Line No." := 10000;
          LoyaltyItemPointSetup.SetFilter (Code, '=%1', Code);
          if (LoyaltyItemPointSetup.FindLast()) then
            "Line No." += LoyaltyItemPointSetup."Line No.";
        end;
    end;
}

