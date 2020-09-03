table 6150669 "NPR NPRE Restaurant Setup"
{
    // NPR5.34/ANEN/2017012  CASE 270255 Object Created for Hospitality - Version 1.0
    // NPR5.35/ANEN/20170821 CASE 283376 Solution rename to NP Restaurant
    // NPR5.52/ALPO/20190813 CASE 360258 Location specific setting of 'Auto print kintchen order'
    //                                   Field 'Auto print kintchen order' type changed from boolean to option
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Restaurant Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(10; "Waiter Pad No. Serie"; Code[10])
        {
            Caption = 'Waiter Pad No. Serie';
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
        }
        field(11; "Kitchen Order Template"; Code[20])
        {
            Caption = 'Kitchen Order Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
            ValidateTableRelation = true;
        }
        field(12; "Pre Receipt Template"; Code[20])
        {
            Caption = 'Pre Receipt Template';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header".Code;
        }
        field(13; "Auto Send Kitchen Order"; Option)
        {
            Caption = 'Auto Send Kitchen Order';
            DataClassification = CustomerContent;
            Description = 'NPR5.52,NPR5.54';
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = No,Yes,Ask;
        }
        field(14; "Resend All On New Lines"; Option)
        {
            Caption = 'Resend All On New Lines';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'No,Yes,Ask';
            OptionMembers = No,Yes,Ask;
        }
        field(15; "Serving Step Discovery Method"; Option)
        {
            Caption = 'Serving Step Discovery Method';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            InitValue = "Item Routing Profiles";
            OptionCaption = 'Legacy (using print tags),Item Routing Profiles';
            OptionMembers = "Legacy (using print tags)","Item Routing Profiles";
        }
        field(20; "Kitchen Printing Active"; Boolean)
        {
            Caption = 'Kitchen Printing Active';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(30; "KDS Active"; Boolean)
        {
            Caption = 'KDS Active';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(60; "Order ID Assign. Method"; Option)
        {
            Caption = 'Order ID Assign. Method';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            OptionCaption = 'Same for Source Document,New Each Time';
            OptionMembers = "Same for Source Document","New Each Time";
        }
        field(70; "Seat.Status: Ready"; Code[10])
        {
            Caption = 'Seat.Status: Ready';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(71; "Seat.Status: Occupied"; Code[10])
        {
            Caption = 'Seat.Status: Occupied';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(72; "Seat.Status: Reserved"; Code[10])
        {
            Caption = 'Seat.Status: Reserved';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(73; "Seat.Status: Cleaning Required"; Code[10])
        {
            Caption = 'Seat.Status: Cleaning Required';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Flow Status".Code WHERE("Status Object" = CONST(Seating));
        }
        field(90; "Default Service Flow Profile"; Code[20])
        {
            Caption = 'Default Service Flow Profile';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
            TableRelation = "NPR NPRE Serv.Flow Profile";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

