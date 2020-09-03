table 6151137 "NPR TM Waiting List Setup"
{
    // TM1.45/TSA /20191203 CASE 380754 Initial Version

    Caption = 'Waiting List Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR TM Waiting List Setup";
    LookupPageID = "NPR TM Waiting List Setup";

    fields
    {
        field(1; "Code"; Code[10])
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
        field(20; "Simultaneous Notification Cnt."; Integer)
        {
            Caption = 'Simultaneous Notification Cnt.';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(25; "Max Notifications per Address"; Integer)
        {
            Caption = 'Max Notifications per Address';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(30; "Expires In (Minutes)"; Integer)
        {
            Caption = 'Expires In (Minutes)';
            DataClassification = CustomerContent;
            InitValue = 30;
            MinValue = 1;
        }
        field(35; "Notification Delay (Minutes)"; Integer)
        {
            Caption = 'Notification Delay  (Minutes)';
            DataClassification = CustomerContent;
        }
        field(40; URL; Text[200])
        {
            Caption = 'URL';
            DataClassification = CustomerContent;
        }
        field(50; "Activate WL at Remaining Qty."; Integer)
        {
            Caption = 'Activate WL at Remaining Qty.';
            DataClassification = CustomerContent;
        }
        field(55; "Remaing Capacity Threshold"; Integer)
        {
            Caption = 'Remaing Capacity Threshold';
            DataClassification = CustomerContent;
        }
        field(61; "Notify Daily From Time"; Time)
        {
            Caption = 'Notify Daily From Time';
            DataClassification = CustomerContent;
            InitValue = 070000T;
        }
        field(62; "Notify Daily Until Time"; Time)
        {
            Caption = 'Notify Daily Until Time';
            DataClassification = CustomerContent;
            InitValue = 210000T;
        }
        field(65; "End Notify Before (Days)"; DateFormula)
        {
            Caption = 'End Notify Before Start (Days)';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin

                if (Format("End Notify Before (Days)") <> '') then
                    Clear("End Notify Before (Minutes)");
            end;
        }
        field(66; "End Notify Before (Minutes)"; Integer)
        {
            Caption = 'End Notify Before Start (Minutes)';
            DataClassification = CustomerContent;
            MaxValue = 1440;
            MinValue = 0;

            trigger OnValidate()
            begin

                if ("End Notify Before (Minutes)" <> 0) then
                    Clear("End Notify Before (Days)");
            end;
        }
        field(75; "Enforce Same Item"; Boolean)
        {
            Caption = 'Enforce Same Item';
            DataClassification = CustomerContent;
        }
        field(80; "Notify On Opt-In"; Boolean)
        {
            Caption = 'Notify On Opt-In';
            DataClassification = CustomerContent;
        }
        field(85; "Notify On Opt-Out"; Boolean)
        {
            Caption = 'Notify On Opt-Out';
            DataClassification = CustomerContent;
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

