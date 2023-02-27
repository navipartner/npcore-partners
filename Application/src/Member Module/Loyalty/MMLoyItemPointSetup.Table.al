table 6060142 "NPR MM Loy. Item Point Setup"
{
    Access = Internal;

    Caption = 'Loyalty Item Point Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Setup";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Item Group,Item,Vendor';
            OptionMembers = "Item Group",Item,Vendor;
        }
        field(11; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF (Type = CONST("Item Group")) "Item Category"
            ELSE
            IF (Type = CONST(Item)) Item
            ELSE
            IF (Type = CONST(Vendor)) Vendor;

            trigger OnValidate()
            var
                Item: Record Item;
                ItemCategory: Record "Item Category";
                Vendor: Record Vendor;
            begin
                case Type of
                    Type::Item:
                        if (Item.Get("No.")) then
                            Description := Item.Description;
                    Type::"Item Group":
                        if (ItemCategory.Get("No.")) then
                            Description := ItemCategory.Description;
                    Type::Vendor:
                        if (Vendor.Get("No.")) then
                            Description := Vendor.Name;
                end;
            end;
        }
        field(12; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Constraint; Option)
        {
            Caption = 'Constraint';
            DataClassification = CustomerContent;
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
        field(21; "Allow On Discounted Sale"; Boolean)
        {
            Caption = 'Allow On Discounted Sale';
            DataClassification = CustomerContent;
        }
        field(25; "Valid From Date"; Date)
        {
            Caption = 'Valid From Date';
            DataClassification = CustomerContent;
        }
        field(26; "Valid Until Date"; Date)
        {
            Caption = 'Valid Until Date';
            DataClassification = CustomerContent;
        }
        field(30; Award; Option)
        {
            Caption = 'Award';
            DataClassification = CustomerContent;
            InitValue = AMOUNT;
            OptionCaption = ' ,Points,Amount,Points+Amount';
            OptionMembers = NA,POINTS,AMOUNT,POINTS_AND_AMOUNT;
        }
        field(31; Points; Integer)
        {
            Caption = 'Points';
            DataClassification = CustomerContent;
        }
        field(32; "Amount Factor"; Decimal)
        {
            Caption = 'Amount Factor';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
    }

    keys
    {
        key(Key1; "Code", "Line No.")
        {
        }
        key(Key2; Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    var
        LoyaltyItemPointSetup: Record "NPR MM Loy. Item Point Setup";
    begin

        if ("Line No." = 0) then begin
            "Line No." := 10000;
            LoyaltyItemPointSetup.SetFilter(Code, '=%1', Code);
            if (LoyaltyItemPointSetup.FindLast()) then
                "Line No." += LoyaltyItemPointSetup."Line No.";
        end;
    end;
}

