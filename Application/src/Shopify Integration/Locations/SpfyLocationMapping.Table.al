#if not BC17
table 6150808 "NPR Spfy Location Mapping"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Location Mapping';
    LookupPageId = "NPR Spfy Location Mapping";
    DrillDownPageId = "NPR Spfy Location Mapping";

    fields
    {
        field(1; "Store Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
            TableRelation = "NPR NpEc Store";
            NotBlank = true;
        }
        field(2; "Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(3; "From Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'From Post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code" else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;
        }
        field(4; "To Post Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'To Post Code';
            TableRelation = if ("Country/Region Code" = const('')) "Post Code" else
            if ("Country/Region Code" = filter(<> '')) "Post Code" where("Country/Region Code" = field("Country/Region Code"));
            ValidateTableRelation = false;
        }
        field(5; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location where("Use As In-Transit" = const(false));
        }
        field(6; "Shipping Agent Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Agent Code';
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            begin
                if "Shipping Agent Code" <> xRec."Shipping Agent Code" then
                    "Shipping Agent Service Code" := '';
            end;
        }
        field(7; "Shipping Agent Service Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
    }

    keys
    {
        key(PK; "Store Code", "Country/Region Code", "From Post Code")
        {
            Clustered = true;
        }
    }
}
#endif