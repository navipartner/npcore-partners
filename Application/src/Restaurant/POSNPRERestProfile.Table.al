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
                if "Restaurant Code" <> xRec."Restaurant Code" then begin
                    "Default Seating Location" := '';
                    "Dine-in Seating Code" := KeepSeatingOfRestaurant("Dine-in Seating Code");
                    "Take-away Seating Code" := KeepSeatingOfRestaurant("Take-away Seating Code");
                    "Pick-up Seating Code" := KeepSeatingOfRestaurant("Pick-up Seating Code");
                end;
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
        field(50; "Take-away VAT Bus. Post. Group"; Code[20])
        {
            Caption = 'Take-away VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(60; "Dine-in Seating Code"; Code[20])
        {
            Caption = 'Dine-in Seating Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating";

            trigger OnValidate()
            begin
                CheckSelfServiceSeating("Dine-in Seating Code");
            end;
        }
        field(70; "Take-away Seating Code"; Code[20])
        {
            Caption = 'Take-away Seating Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating";

            trigger OnValidate()
            begin
                CheckSelfServiceSeating("Take-away Seating Code");
            end;
        }
        field(80; "Pick-up Seating Code"; Code[20])
        {
            Caption = 'Pick-up Seating Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Seating";

            trigger OnValidate()
            begin
                CheckSelfServiceSeating("Pick-up Seating Code");
            end;
        }
        field(90; "Dine-in VAT Bus. Post. Group"; Code[20])
        {
            Caption = 'Dine-in VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    local procedure CheckSelfServiceSeating(SeatingCode: Code[20])
    var
        Seating: Record "NPR NPRE Seating";
        Restaurant: Record "NPR NPRE Restaurant";
        SeatingOfOtherRestaurantErr: Label '%1 %2 does not belong to %3 %4.', Comment = '%1 = Seating table caption, %2 = seating code, %3 = Restaurant table caption, %4 = restaurant code';
    begin
        if SeatingCode = '' then
            exit;
        Seating.SetLoadFields(Blocked, "Seating Location");
        Seating.Get(SeatingCode);
        Seating.TestField(Blocked, false);
        // These fields have higher field numbers than "Restaurant Code", like "Default Seating Location", so imports that
        // validate in field order set the restaurant first. Without a restaurant there is nothing to compare with yet;
        // the "Restaurant Code" OnValidate clears seatings of other restaurants once it is set.
        if "Restaurant Code" = '' then
            exit;
        if Seating.GetSeatingRestaurant() <> "Restaurant Code" then
            Error(SeatingOfOtherRestaurantErr, Seating.TableCaption(), SeatingCode, Restaurant.TableCaption(), "Restaurant Code");
    end;

    local procedure KeepSeatingOfRestaurant(SeatingCode: Code[20]): Code[20]
    var
        Seating: Record "NPR NPRE Seating";
    begin
        if SeatingCode = '' then
            exit('');
        Seating.SetLoadFields("Seating Location");
        if Seating.Get(SeatingCode) then
            if Seating.GetSeatingRestaurant() = "Restaurant Code" then
                exit(SeatingCode);
        exit('');
    end;
}
