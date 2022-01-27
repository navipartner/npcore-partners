table 6151058 "NPR Distribution Lines"
{
    Access = Internal;
    Caption = 'Distribution Lines';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Distribution Id"; Integer)
        {
            Caption = 'Distribution Id';
            DataClassification = CustomerContent;
        }
        field(2; "Distribution Line"; Integer)
        {
            Caption = 'Distribution Line';
            DataClassification = CustomerContent;
        }
        field(5; "Distribution Group Member"; Code[20])
        {
            Caption = 'Distribution Group Member';
            DataClassification = CustomerContent;
        }
        field(6; Location; Code[10])
        {
            Caption = 'Location';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(7; "Distribution Item"; Code[20])
        {
            Caption = 'Distribution Item';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(8; "Item Hiearachy"; Code[20])
        {
            Caption = 'Item Hiearachy';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Hierarchy";
        }
        field(9; "Item Hiearachy Level"; Integer)
        {
            Caption = 'Item Hiearachy Level';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Item Variant"; Code[20])
        {
            Caption = 'Item Variant';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant";
        }
        field(20; "Distribution Quantity"; Decimal)
        {
            Caption = 'Distribution Quantity';
            DataClassification = CustomerContent;
        }
        field(21; "Org. Distribution Quantity"; Decimal)
        {
            Caption = 'Org. Distribution Quantity';
            DataClassification = CustomerContent;
        }
        field(30; "Distribution Cost Value (LCY)"; Decimal)
        {
            Caption = 'Distribution Cost Value (LCY)';
            DataClassification = CustomerContent;
        }
        field(40; "Avaliable Quantity"; Decimal)
        {
            Caption = 'Avaliable Quantity';
            DataClassification = CustomerContent;
        }
        field(50; "Demanded Quantity"; Decimal)
        {
            Caption = 'Demanded Quantity';
            DataClassification = CustomerContent;
        }
        field(100; "Date Created"; Date)
        {
            Caption = 'Date Created';
            DataClassification = CustomerContent;
        }
        field(101; "Date Required"; Date)
        {
            Caption = 'Date Required';
            DataClassification = CustomerContent;
        }
        field(200; "Action Required"; Option)
        {
            Caption = 'Action Required';
            DataClassification = CustomerContent;
            OptionCaption = 'Skip,Purchase,Transfer,Completed,Done';
            OptionMembers = Skip,Purchase,Transfer,Completed,Done;
        }
        field(300; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(301; "Purchase Order Line"; Integer)
        {
            Caption = 'Purchase Order Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(302; "Qty On PO"; Decimal)
        {
            CalcFormula = Sum("NPR Distribution Map".Quantity
                            where(
                                "Distribution Id" = field("Distribution Id"),
                                "Table Id" = const(39), // Purchase Line
                                "Item No." = field("Distribution Item"),
                                "Location Code" = field(Location)));
            Caption = 'Qty On PO';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310; "Transfer Order No."; Code[20])
        {
            Caption = 'Transfer Order No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(311; "Transfer Order Line"; Integer)
        {
            Caption = 'Transfer Order Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(312; "Qty On Transfer"; Decimal)
        {
            CalcFormula = Sum("NPR Distribution Map".Quantity
                            where(
                                "Distribution Id" = field("Distribution Id"),
                                "Table Id" = const(5741), // Transfer Line
                                "Item No." = field("Distribution Item"),
                                "Location Code" = field(Location)));
            Caption = 'Qty On Transfer';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Distribution Id", "Distribution Line")
        {
        }
        key(Key2; Location, "Distribution Item")
        {
        }
    }

    fieldgroups
    {
    }
}

