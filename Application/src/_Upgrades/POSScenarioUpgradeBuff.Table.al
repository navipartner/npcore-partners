table 6150852 "NPR POS Scenario Upgrade Buff"
{
    DataClassification = CustomerContent;
    Access = Internal;
    TableType = Temporary;
    Caption = 'POS Scenario Upgrade Buff';

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(2; "Bin Eject After Credit Sale"; Boolean)
        {
            Caption = 'Bin Eject After Credit Sale';
            DataClassification = CustomerContent;
        }
        field(3; "Bin Eject After Sale"; Boolean)
        {
            Caption = 'Bin Eject After Sale';
            DataClassification = CustomerContent;
        }
        field(4; "Do Not Print Receipt on Sale"; Boolean)
        {
            Caption = 'Do Not Print Receipt on Sale';
            DataClassification = CustomerContent;
        }
        field(5; "Assign Loyalty On Sale"; Boolean)
        {
            Caption = 'Assign Loyalty On Sale';
            DataClassification = CustomerContent;
        }
        field(6; "Print Membership On Sale"; Boolean)
        {
            Caption = 'Print Membership On Sale';
            DataClassification = CustomerContent;
        }
        field(7; "Send Notification On Sale"; Boolean)
        {
            Caption = 'Send Notification On Sale';
            DataClassification = CustomerContent;
        }
        field(8; "Print Ticket On Sale"; Boolean)
        {
            Caption = 'Print Ticket On Sale';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

}