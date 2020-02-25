table 6151137 "TM Waiting List Setup"
{
    // TM1.45/TSA /20191203 CASE 380754 Initial Version

    Caption = 'Waiting List Setup';
    DrillDownPageID = "TM Waiting List Setup";
    LookupPageID = "TM Waiting List Setup";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Simultaneous Notification Cnt.";Integer)
        {
            Caption = 'Simultaneous Notification Cnt.';
            InitValue = 1;
        }
        field(25;"Max Notifications per Address";Integer)
        {
            Caption = 'Max Notifications per Address';
            InitValue = 1;
        }
        field(30;"Expires In (Minutes)";Integer)
        {
            Caption = 'Expires In (Minutes)';
            InitValue = 30;
            MinValue = 1;
        }
        field(35;"Notification Delay (Minutes)";Integer)
        {
            Caption = 'Notification Delay  (Minutes)';
        }
        field(40;URL;Text[200])
        {
            Caption = 'URL';
        }
        field(50;"Activate WL at Remaining Qty.";Integer)
        {
            Caption = 'Activate WL at Remaining Qty.';
        }
        field(55;"Remaing Capacity Threshold";Integer)
        {
            Caption = 'Remaing Capacity Threshold';
        }
        field(61;"Notify Daily From Time";Time)
        {
            Caption = 'Notify Daily From Time';
            InitValue = 070000T;
        }
        field(62;"Notify Daily Until Time";Time)
        {
            Caption = 'Notify Daily Until Time';
            InitValue = 210000T;
        }
        field(65;"End Notify Before (Days)";DateFormula)
        {
            Caption = 'End Notify Before Start (Days)';

            trigger OnValidate()
            begin

                if (Format ("End Notify Before (Days)") <> '') then
                  Clear ("End Notify Before (Minutes)");
            end;
        }
        field(66;"End Notify Before (Minutes)";Integer)
        {
            Caption = 'End Notify Before Start (Minutes)';
            MaxValue = 1440;
            MinValue = 0;

            trigger OnValidate()
            begin

                if ("End Notify Before (Minutes)" <> 0) then
                  Clear ("End Notify Before (Days)");
            end;
        }
        field(75;"Enforce Same Item";Boolean)
        {
            Caption = 'Enforce Same Item';
        }
        field(80;"Notify On Opt-In";Boolean)
        {
            Caption = 'Notify On Opt-In';
        }
        field(85;"Notify On Opt-Out";Boolean)
        {
            Caption = 'Notify On Opt-Out';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

