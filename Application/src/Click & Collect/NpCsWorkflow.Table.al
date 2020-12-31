table 6151196 "NPR NpCs Workflow"
{
    Caption = 'Collect Workflow';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpCs Workflows";
    LookupPageID = "NPR NpCs Workflows";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(100; "Send Order Module"; Code[20])
        {
            Caption = 'Send Order Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow Module".Code WHERE(Type = CONST("Send Order"));
        }
        field(105; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Shipment Method";
        }
        field(110; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(115; "Notify Store via E-mail"; Boolean)
        {
            Caption = 'Notify Store via E-mail';
            DataClassification = CustomerContent;
        }
        field(120; "Store E-mail Temp. (Pending)"; Code[20])
        {
            Caption = 'Store E-mail Template (Pending)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(122; "Store E-mail Temp. (Expired)"; Code[20])
        {
            Caption = 'Store E-mail Template (Expired)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(125; "Notify Store via Sms"; Boolean)
        {
            Caption = 'Notify Store via Sms';
            DataClassification = CustomerContent;
        }
        field(130; "Store Sms Template (Pending)"; Code[10])
        {
            Caption = 'Store Sms Template (Pending)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(132; "Store Sms Template (Expired)"; Code[10])
        {
            Caption = 'Store Sms Template (Expired)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(135; "Customer Mapping"; Option)
        {
            Caption = 'Customer Mapping';
            DataClassification = CustomerContent;
            OptionCaption = ' ,E-mail,Phone No.,E-mail AND Phone No.,E-mail OR Phone No.,Fixed Customer No.,Customer No. from Source';
            OptionMembers = " ","E-mail","Phone No.","E-mail AND Phone No.","E-mail OR Phone No.","Fixed Customer No.","Customer No. from Source";
        }
        field(140; "Fixed Customer No."; Code[20])
        {
            Caption = 'Fixed Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(145; "Processing Expiry Duration"; Duration)
        {
            Caption = 'Processing Expiry Duration';
            DataClassification = CustomerContent;
        }
        field(150; "Delivery Expiry Days (Qty.)"; Integer)
        {
            Caption = 'Delivery Expiry Days (Qty.)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(200; "Order Status Module"; Code[20])
        {
            Caption = 'Order Status Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow Module".Code WHERE(Type = CONST("Order Status"));
        }
        field(207; "Send Notification from Store"; Boolean)
        {
            Caption = 'Send Notification from Store';
            DataClassification = CustomerContent;
        }
        field(210; "Notify Customer via E-mail"; Boolean)
        {
            Caption = 'Notify Customer via E-mail';
            DataClassification = CustomerContent;
        }
        field(213; "E-mail Template (Pending)"; Code[20])
        {
            Caption = 'E-mail Template (Pending)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(215; "E-mail Template (Confirmed)"; Code[20])
        {
            Caption = 'E-mail Template (Confirmed)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(220; "E-mail Template (Rejected)"; Code[20])
        {
            Caption = 'E-mail Template (Rejected)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(225; "E-mail Template (Expired)"; Code[20])
        {
            Caption = 'E-mail Template (Expired)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(230; "Notify Customer via Sms"; Boolean)
        {
            Caption = 'Notify Customer via Sms';
            DataClassification = CustomerContent;
        }
        field(233; "Sms Template (Pending)"; Code[10])
        {
            Caption = 'Sms Template (Pending)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(235; "Sms Template (Confirmed)"; Code[10])
        {
            Caption = 'Sms Template (Confirmed)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(240; "Sms Template (Rejected)"; Code[10])
        {
            Caption = 'Sms Template (Rejected)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(245; "Sms Template (Expired)"; Code[10])
        {
            Caption = 'Sms Template (Expired)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(300; "Post Processing Module"; Code[20])
        {
            Caption = 'Post Processing Module';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow Module".Code WHERE(Type = CONST("Post Processing"));
        }
        field(305; "Archive on Delivery"; Boolean)
        {
            Caption = 'Archive on Delivery';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(350; "Store Stock"; Boolean)
        {
            Caption = 'Store Stock';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            InitValue = true;
        }
        field(360; "Post on"; Option)
        {
            Caption = 'Post on';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            OptionCaption = 'Delivery,Processing';
            OptionMembers = Delivery,Processing;

            trigger OnValidate()
            begin
                "Bill via" := "Bill via"::"Sales Document";
            end;
        }
        field(380; "Bill via"; Option)
        {
            Caption = 'Bill via';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            OptionCaption = 'POS,Sales Document';
            OptionMembers = POS,"Sales Document";

            trigger OnValidate()
            begin
                case "Bill via" of
                    "Bill via"::POS:
                        begin
                            TestField("Post on", "Post on"::Delivery);
                        end;
                end;
            end;
        }
        field(400; "Processing Print Template"; Code[20])
        {
            Caption = 'Processing Print Template';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(410; "Delivery Print Template (POS)"; Code[20])
        {
            Caption = 'Delivery Print Template (POS)';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(420; "Delivery Print Template (S.)"; Code[20])
        {
            Caption = 'Delivery Template (Sales Document)';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }
}

