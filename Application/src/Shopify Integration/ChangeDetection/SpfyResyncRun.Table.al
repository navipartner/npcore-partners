table 6059979 "NPR Spfy Resync Run"
{
    Access = Internal;
    Caption = 'Shopify Re-sync Run';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Scope; Option)
        {
            Caption = 'Scope';
            OptionMembers = "Full Resync",Area,Store,"Table","Quiet Seed";
            OptionCaption = 'Full Re-sync,Area,Store,Table,Quiet Seed';
            DataClassification = CustomerContent;
        }
        field(11; "Integration Area"; Enum "NPR Spfy Integration Area")
        {
            Caption = 'Integration Area';
            DataClassification = CustomerContent;
        }
        field(12; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            TableRelation = "NPR Spfy Store";
            DataClassification = CustomerContent;
        }
        field(13; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(14; "Include Store-Agnostic"; Boolean)
        {
            Caption = 'Include Store-Agnostic Facets';
            DataClassification = CustomerContent;
        }
        field(15; "Launch Mode"; Option)
        {
            Caption = 'Launch Mode';
            OptionMembers = Foreground,Background;
            OptionCaption = 'Foreground,Background';
            DataClassification = CustomerContent;
        }
        field(20; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Running,Completed,Failed;
            OptionCaption = 'Running,Completed,Failed';
            DataClassification = CustomerContent;
        }
        field(30; "Started At"; DateTime)
        {
            Caption = 'Started At';
            DataClassification = CustomerContent;
        }
        field(31; "Heartbeat At"; DateTime)
        {
            Caption = 'Heartbeat At';
            DataClassification = CustomerContent;
        }
        field(32; "Completed At"; DateTime)
        {
            Caption = 'Completed At';
            DataClassification = CustomerContent;
        }
        field(40; "Baselines Cleared"; Integer)
        {
            Caption = 'Baselines Cleared';
            DataClassification = CustomerContent;
        }
        field(41; "Marks Reset"; Integer)
        {
            Caption = 'Marks Reset';
            DataClassification = CustomerContent;
        }
        field(42; "Entities Processed"; Integer)
        {
            // Quiet-seed only; bulk scopes report "Baselines Cleared" / "Marks Reset" instead.
            Caption = 'Entities Processed';
            DataClassification = CustomerContent;
        }
        field(50; "Error Text"; Text[250])
        {
            Caption = 'Error Text';
            DataClassification = CustomerContent;
        }
        field(60; "Run By"; Code[50])
        {
            Caption = 'Run By';
            DataClassification = EndUserIdentifiableInformation;
        }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ActiveRuns; Status, "Heartbeat At") { }
    }
}
