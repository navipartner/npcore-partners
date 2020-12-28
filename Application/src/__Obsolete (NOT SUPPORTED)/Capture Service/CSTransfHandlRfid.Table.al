table 6151364 "NPR CS Transf. Handl. Rfid"
{
   
    Caption = 'CS Transfer Handling Rfid';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.'; 


    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
        }
        field(10; "Rfid Header Id"; Guid)
        {
            Caption = 'Rfid Header Id';
            DataClassification = CustomerContent;
        }
        field(11; "Batch Id"; Guid)
        {
            Caption = 'Batch Id';
            DataClassification = CustomerContent;
        }
        field(12; "Request Data"; BLOB)
        {
            Caption = 'Request Data';
            DataClassification = CustomerContent;
        }
        field(14; "Response Data"; BLOB)
        {
            Caption = 'Response Data';
            DataClassification = CustomerContent;
        }
        field(15; "Batch No."; Integer)
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(16; "Device Id"; Code[10])
        {
            Caption = 'Device Id';
            DataClassification = CustomerContent;
        }
        field(19; Tags; Integer)
        {
            Caption = 'Tags';
            DataClassification = CustomerContent;
        }
        field(20; Handled; Boolean)
        {
            Caption = 'Handled';
            DataClassification = CustomerContent;
        }
        field(21; Created; DateTime)
        {
            Caption = 'Created';
            DataClassification = CustomerContent;
        }
        field(22; "Created By"; Code[20])
        {
            Caption = 'Created By';
            DataClassification = CustomerContent;
        }
        field(24; "Posting Started"; DateTime)
        {
            Caption = 'Posting Started';
            DataClassification = CustomerContent;
        }
        field(25; "Posting Ended"; DateTime)
        {
            Caption = 'Posting Ended';
            DataClassification = CustomerContent;
        }
        field(28; "Area"; Option)
        {
            Caption = 'Area';
            DataClassification = CustomerContent;
            OptionCaption = 'Shipping,Receiving';
            OptionMembers = Shipping,Receiving;
        }
    }

    keys
    {
        key(Key1; Id)
        {
        }
        key(Key2; Created)
        {
        }
    }

    fieldgroups
    {
    }
}

