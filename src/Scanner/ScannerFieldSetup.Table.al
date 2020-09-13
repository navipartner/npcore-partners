table 6014448 "NPR Scanner: Field Setup"
{
    // NPR5.40/BHR/20180326 CASE 308408 Rename field 8 Where to "Where To"

    Caption = 'Scanner - Field Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Code[20])
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = ' ,ItemNo,Quantity,Placement,Color,Size,Code,Scanner No,Serial No,KolliAntal,Item Description,Sign,Unit Price,Unit Cost,Inventory,EAN,Text,Date,Time,DateTime';
            OptionMembers = " ",ItemNo,Quantity,Placement,Color,Size,"Code",ScannerNo,SerialNo,KolliAntal,"Item Description",Sign,"Unit Price","Unit Cost",Inventory,EAN,Text,Date,Time,DateTime;
            DataClassification = CustomerContent;
        }
        field(3; Prefix; Code[10])
        {
            Caption = 'Prefix';
            DataClassification = CustomerContent;
        }
        field(4; Position; Integer)
        {
            Caption = 'Position';
            DataClassification = CustomerContent;
        }
        field(5; Length; Integer)
        {
            Caption = 'Length';
            DataClassification = CustomerContent;
        }
        field(6; Postfix; Text[5])
        {
            Caption = 'Postfix';
            DataClassification = CustomerContent;
        }
        field(7; Order; Integer)
        {
            Caption = 'Order';
            DataClassification = CustomerContent;
        }
        field(8; "Where To"; Option)
        {
            Caption = 'Where';
            OptionCaption = 'Input,Output';
            OptionMembers = Input,Output;
            DataClassification = CustomerContent;
        }
        field(9; Padding; Option)
        {
            Caption = 'Padding';
            OptionCaption = ' ,Pre Zeroes,Leading Spaces';
            OptionMembers = " ","Pre Zeroes","Leading Spaces";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ID, "Where To", Type, "Order")
        {
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

