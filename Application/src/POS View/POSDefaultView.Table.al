table 6150711 "NPR POS Default View"
{
    Access = Internal;
    Caption = 'POS Default View';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            AutoIncrement = true;
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Login,Sale,Payment,Balance,Locked,Restaurant';
            OptionMembers = Login,Sale,Payment,Balance,Locked,Restaurant;
        }
        field(3; "Salesperson Filter"; Text[250])
        {
            Caption = 'Salesperson Filter';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                SalespersonList: Page "NPR Salespers/PurchSelect";
            begin
                SalespersonList.LookupMode(true);
                if SalespersonList.RunModal() = Action::LookupOK then
                    Validate("Salesperson Filter", SalespersonList.GetSelectionFilter());
            end;
        }
        field(4; "Register Filter"; Text[250])
        {
            Caption = 'POS Unit No. Filter';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                POSUnitList: Page "NPR POS Unit List";
            begin
                POSUnitList.LookupMode(true);
                if POSUnitList.RunModal() = Action::LookupOK then
                    Validate("Register Filter", POSUnitList.GetSelectionFilter());
            end;
        }
        field(5; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
            DataClassification = CustomerContent;
        }
        field(6; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
            DataClassification = CustomerContent;
        }
        field(7; Monday; Boolean)
        {
            Caption = 'Monday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(8; Tuesday; Boolean)
        {
            Caption = 'Tuesday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(9; Wednesday; Boolean)
        {
            Caption = 'Wednesday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(10; Thursday; Boolean)
        {
            Caption = 'Thursday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(11; Friday; Boolean)
        {
            Caption = 'Friday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(12; Saturday; Boolean)
        {
            Caption = 'Saturday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(13; Sunday; Boolean)
        {
            Caption = 'Sunday';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(21; "POS View Code"; Code[10])
        {
            Caption = 'POS View Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS View";
        }
    }

    keys
    {
        key(Key1; ID)
        {
        }
    }
}
