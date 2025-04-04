tableextension 6014454 "NPR User Setup" extends "User Setup"
{
    fields
    {
        field(6014400; "NPR Backoffice Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(6014401; "NPR POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(6014405; "NPR Allow Register Switch"; Boolean)
        {
            Caption = 'Allow POS Unit Switch';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            TableRelation = "NPR POS Unit";
            ValidateTableRelation = false;
        }
        field(6060150; "NPR MM Allow MS Entry Edit"; Boolean)
        {
            Caption = 'Allow Membership Entry Edit';
            DataClassification = CustomerContent;
        }
        field(6014410; "NPR Register Switch Filter"; Text[100])
        {
            Caption = 'POS Unit Switch Filter';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                POSUnitList: Page "NPR POS Unit List";
            begin
                POSUnitList.LookupMode(true);
                if POSUnitList.RunModal() = Action::LookupOK then
                    Validate("NPR Register Switch Filter", POSUnitList.GetSelectionFilter());
            end;
        }
        field(6150640; "NPR Allow Restaurant Switch"; Boolean)
        {
            Caption = 'Allow Restaurant Switch';
            DataClassification = CustomerContent;
        }
        field(6150650; "NPR Restaurant Switch Filter"; Text[100])
        {
            Caption = 'Restaurant Switch Filter';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                RestaurantList: Page "NPR NPRE Restaurants";
            begin
                RestaurantList.LookupMode(true);
                if RestaurantList.RunModal() = Action::LookupOK then
                    Validate("NPR Restaurant Switch Filter", RestaurantList.GetSelectionFilter());
            end;
        }
        field(6150660; "NPR Backoffice Restaurant Code"; Code[20])
        {
            Caption = 'Backoffice Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
        }
        field(6151060; "NPR Anonymize Customers"; Boolean)
        {
            Caption = 'Anonymize Customers';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
        field(6151070; "NPR Block Role Center"; Boolean)
        {
            Caption = 'Block Role Center';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
    }
}
