table 6151196 "NpCs Workflow"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // #362443/MHA /20190723  CASE 362443 Removed unused field 205 "Auto Post Order on"

    Caption = 'Collect Workflow';
    DrillDownPageID = "NpCs Workflows";
    LookupPageID = "NpCs Workflows";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(100; "Send Order Module"; Code[20])
        {
            Caption = 'Send Order Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type = CONST ("Send Order"));
        }
        field(105; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(110; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(115; "Notify Store via E-mail"; Boolean)
        {
            Caption = 'Notify Store via E-mail';
        }
        field(120; "E-mail Template"; Code[20])
        {
            Caption = 'E-mail Template';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(125; "Notify Store via Sms"; Boolean)
        {
            Caption = 'Notify Store via Sms';
        }
        field(130; "Sms Template"; Code[10])
        {
            Caption = 'Sms Template';
            TableRelation = "SMS Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(135; "Customer Mapping"; Option)
        {
            Caption = 'Customer Mapping';
            OptionCaption = ' ,E-mail,Phone No.,E-mail AND Phone No.,E-mail OR Phone No.,Fixed Customer No.,Customer No. from Source';
            OptionMembers = " ","E-mail","Phone No.","E-mail AND Phone No.","E-mail OR Phone No.","Fixed Customer No.","Customer No. from Source";
        }
        field(140; "Fixed Customer No."; Code[20])
        {
            Caption = 'Fixed Customer No.';
            TableRelation = Customer;
        }
        field(145; "Processing Expiry Duration"; Duration)
        {
            Caption = 'Processing Expiry Duration';
        }
        field(150; "Delivery Expiry Days (Qty.)"; Integer)
        {
            Caption = 'Delivery Expiry Days (Qty.)';
            MinValue = 0;
        }
        field(200; "Order Status Module"; Code[20])
        {
            Caption = 'Order Status Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type = CONST ("Order Status"));
        }
        field(207; "Send Notification from Store"; Boolean)
        {
            Caption = 'Send Notification from Store';
        }
        field(210; "Notify Customer via E-mail"; Boolean)
        {
            Caption = 'Notify Customer via E-mail';
        }
        field(213; "E-mail Template (Pending)"; Code[20])
        {
            Caption = 'E-mail Template (Pending)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(215; "E-mail Template (Confirmed)"; Code[20])
        {
            Caption = 'E-mail Template (Confirmed)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(220; "E-mail Template (Rejected)"; Code[20])
        {
            Caption = 'E-mail Template (Rejected)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(225; "E-mail Template (Expired)"; Code[20])
        {
            Caption = 'E-mail Template (Expired)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(230; "Notify Customer via Sms"; Boolean)
        {
            Caption = 'Notify Customer via Sms';
        }
        field(233; "Sms Template (Pending)"; Code[10])
        {
            Caption = 'Sms Template (Pending)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(235; "Sms Template (Confirmed)"; Code[10])
        {
            Caption = 'Sms Template (Confirmed)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(240; "Sms Template (Rejected)"; Code[10])
        {
            Caption = 'Sms Template (Rejected)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(245; "Sms Template (Expired)"; Code[10])
        {
            Caption = 'Sms Template (Expired)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No." = CONST (6151198));
        }
        field(300; "Post Processing Module"; Code[20])
        {
            Caption = 'Post Processing Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type = CONST ("Post Processing"));
        }
        field(305; "Archive on Delivery"; Boolean)
        {
            Caption = 'Archive on Delivery';
            InitValue = true;
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

