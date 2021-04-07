table 6014448 "NPR Scanner: Field Setup"
{
    Caption = 'Scanner - Field Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used.';

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,ItemNo,Quantity,Placement,Color,Size,Code,Scanner No,Serial No,KolliAntal,Item Description,Sign,Unit Price,Unit Cost,Inventory,EAN,Text,Date,Time,DateTime';
            OptionMembers = " ",ItemNo,Quantity,Placement,Color,Size,"Code",ScannerNo,SerialNo,KolliAntal,"Item Description",Sign,"Unit Price","Unit Cost",Inventory,EAN,Text,Date,Time,DateTime;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(3; Prefix; Code[10])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(4; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(5; Length; Integer)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6; Postfix; Text[5])
        {
            Caption = 'Postfix';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(7; Order; Integer)
        {
            Caption = 'Order';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(8; "Where To"; Option)
        {
            Caption = 'Where';
            OptionCaption = 'Input,Output';
            OptionMembers = Input,Output;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(9; Padding; Option)
        {
            Caption = 'Padding';
            OptionCaption = ' ,Pre Zeroes,Leading Spaces';
            OptionMembers = " ","Pre Zeroes","Leading Spaces";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
    }

    keys
    {
        key(Key1; ID, "Where To", Type, "Order")
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        key(Key2; Prefix)
        {
        }
        key(Key3; "Order")
        {
        }
    }

    fieldgroups
    {
    }
}