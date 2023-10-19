table 6150655 "NPR POS NPRE Rest. Profile"
{
    Access = Internal;
    Caption = 'POS Restaurant Profile';
    DataClassification = CustomerContent;
    LookupPageID = "NPR POS NPRE Restaur. Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";

            trigger OnValidate()
            begin
                if "Restaurant Code" <> xRec."Restaurant Code" then
                    "Default Seating Location" := '';
            end;
        }
        field(30; "Default Seating Location"; Code[10])
        {
            Caption = 'Default Seating Location';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating Location" where("Restaurant Code" = field("Restaurant Code"));
        }
        field(40; "After End-of-Sale"; Option)
        {
            Caption = 'After End-of-Sale';
            DataClassification = CustomerContent;
            OptionMembers = Default,"Load Next Waiter Pad";
            OptionCaption = 'Default,Load Next Waiter Pad';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}
