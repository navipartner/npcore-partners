table 6059789 "NPR MM Membership Statistics"
{
    Access = Internal;
    Caption = 'MM Membership Statistics';
    DrillDownPageId = "NPR MM Membership Statistics";
    LookupPageId = "NPR MM Membership Statistics";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Reference Date"; Date)
        {
            Caption = 'Reference Date';
            DataClassification = CustomerContent;
        }
        field(10; "First Time Members"; Integer)
        {
            Caption = 'First Time Members';
            DataClassification = CustomerContent;
        }
        field(15; "Recurring Members"; Integer)
        {
            Caption = 'Recurring Members';
            DataClassification = CustomerContent;
        }
        field(20; "Future Members"; Integer)
        {
            Caption = 'Future Members';
            DataClassification = CustomerContent;
        }
        field(30; "First Time Members Last Year"; Integer)
        {
            Caption = 'First Time Members Last Year';
            DataClassification = CustomerContent;
        }
        field(31; "Recurring Members Last Year"; Integer)
        {
            Caption = 'Recurring Members Last Year';
            DataClassification = CustomerContent;
            ;
        }
        field(35; "No. of Members expire CM"; Integer)
        {
            Caption = 'No. of Members expire CM';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Reference Date")
        {
            Clustered = true;
        }
    }
}
