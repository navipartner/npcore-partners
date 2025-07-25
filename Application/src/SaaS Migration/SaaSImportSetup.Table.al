table 6059844 "NPR SaaS Import Setup"
{
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; PK; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Max Background Sessions"; Integer)
        {
            InitValue = 0;
            DataClassification = CustomerContent;
        }
        field(3; "Max Task Scheduler Tasks"; Integer)
        {
            InitValue = 0;
            DataClassification = CustomerContent;
        }
        field(4; "Synchronous Processing"; Boolean)
        {
            InitValue = true;
            DataClassification = CustomerContent;
        }
        field(5; "Disable Database Triggers"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Disable StopSession"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Disable StopSession on Prepare Import', Locked = true;
        }
        field(7; "Disable Event Subscribers"; Boolean)
        {
            Caption = 'Disable Event Subscribers', Locked = true;
            DataClassification = CustomerContent;
        }
    }

}