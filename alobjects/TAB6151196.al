table 6151196 "NpCs Workflow"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.51/MHA /20190723  CASE 362443 Removed unused field 205 "Auto Post Order on"
    // NPR5.51/MHA /20190819  CASE 364557 Added fields 350 "Store Stock", 360 "Post on", 380 "Bill via"
    // NPR5.54/MHA /20200130  CASE 378956 Added Store Notification Fields

    Caption = 'Collect Workflow';
    DrillDownPageID = "NpCs Workflows";
    LookupPageID = "NpCs Workflows";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(100;"Send Order Module";Code[20])
        {
            Caption = 'Send Order Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type=CONST("Send Order"));
        }
        field(105;"Shipment Method Code";Code[10])
        {
            Caption = 'Shipment Method Code';
            TableRelation = "Shipment Method";
        }
        field(110;"Payment Method Code";Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(115;"Notify Store via E-mail";Boolean)
        {
            Caption = 'Notify Store via E-mail';
        }
        field(120;"Store E-mail Temp. (Pending)";Code[20])
        {
            Caption = 'Store E-mail Template (Pending)';
            Description = 'NPR5.54';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(122;"Store E-mail Temp. (Expired)";Code[20])
        {
            Caption = 'Store E-mail Template (Expired)';
            Description = 'NPR5.54';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(125;"Notify Store via Sms";Boolean)
        {
            Caption = 'Notify Store via Sms';
        }
        field(130;"Store Sms Template (Pending)";Code[10])
        {
            Caption = 'Store Sms Template (Pending)';
            Description = 'NPR5.54';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(132;"Store Sms Template (Expired)";Code[10])
        {
            Caption = 'Store Sms Template (Expired)';
            Description = 'NPR5.54';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(135;"Customer Mapping";Option)
        {
            Caption = 'Customer Mapping';
            OptionCaption = ' ,E-mail,Phone No.,E-mail AND Phone No.,E-mail OR Phone No.,Fixed Customer No.,Customer No. from Source';
            OptionMembers = " ","E-mail","Phone No.","E-mail AND Phone No.","E-mail OR Phone No.","Fixed Customer No.","Customer No. from Source";
        }
        field(140;"Fixed Customer No.";Code[20])
        {
            Caption = 'Fixed Customer No.';
            TableRelation = Customer;
        }
        field(145;"Processing Expiry Duration";Duration)
        {
            Caption = 'Processing Expiry Duration';
        }
        field(150;"Delivery Expiry Days (Qty.)";Integer)
        {
            Caption = 'Delivery Expiry Days (Qty.)';
            MinValue = 0;
        }
        field(200;"Order Status Module";Code[20])
        {
            Caption = 'Order Status Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type=CONST("Order Status"));
        }
        field(207;"Send Notification from Store";Boolean)
        {
            Caption = 'Send Notification from Store';
        }
        field(210;"Notify Customer via E-mail";Boolean)
        {
            Caption = 'Notify Customer via E-mail';
        }
        field(213;"E-mail Template (Pending)";Code[20])
        {
            Caption = 'E-mail Template (Pending)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(215;"E-mail Template (Confirmed)";Code[20])
        {
            Caption = 'E-mail Template (Confirmed)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(220;"E-mail Template (Rejected)";Code[20])
        {
            Caption = 'E-mail Template (Rejected)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(225;"E-mail Template (Expired)";Code[20])
        {
            Caption = 'E-mail Template (Expired)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(230;"Notify Customer via Sms";Boolean)
        {
            Caption = 'Notify Customer via Sms';
        }
        field(233;"Sms Template (Pending)";Code[10])
        {
            Caption = 'Sms Template (Pending)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(235;"Sms Template (Confirmed)";Code[10])
        {
            Caption = 'Sms Template (Confirmed)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(240;"Sms Template (Rejected)";Code[10])
        {
            Caption = 'Sms Template (Rejected)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(245;"Sms Template (Expired)";Code[10])
        {
            Caption = 'Sms Template (Expired)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(300;"Post Processing Module";Code[20])
        {
            Caption = 'Post Processing Module';
            TableRelation = "NpCs Workflow Module".Code WHERE (Type=CONST("Post Processing"));
        }
        field(305;"Archive on Delivery";Boolean)
        {
            Caption = 'Archive on Delivery';
            InitValue = true;
        }
        field(350;"Store Stock";Boolean)
        {
            Caption = 'Store Stock';
            Description = 'NPR5.51';
            InitValue = true;
        }
        field(360;"Post on";Option)
        {
            Caption = 'Post on';
            Description = 'NPR5.51';
            OptionCaption = 'Delivery,Processing';
            OptionMembers = Delivery,Processing;

            trigger OnValidate()
            begin
                //-NPR5.51 [364557]
                "Bill via" := "Bill via"::"Sales Document";
                //+NPR5.51 [364557]
            end;
        }
        field(380;"Bill via";Option)
        {
            Caption = 'Bill via';
            Description = 'NPR5.51';
            OptionCaption = 'POS,Sales Document';
            OptionMembers = POS,"Sales Document";

            trigger OnValidate()
            begin
                //-NPR5.51 [364557]
                case "Bill via" of
                  "Bill via"::POS:
                    begin
                      TestField("Post on","Post on"::Delivery);
                    end;
                end;
                //+NPR5.51 [364557]
            end;
        }
        field(400;"Processing Print Template";Code[20])
        {
            Caption = 'Processing Print Template';
            Description = 'NPR5.51';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
        }
        field(410;"Delivery Print Template (POS)";Code[20])
        {
            Caption = 'Delivery Print Template (POS)';
            Description = 'NPR5.51';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
        }
        field(420;"Delivery Print Template (S.)";Code[20])
        {
            Caption = 'Delivery Template (Sales Document)';
            Description = 'NPR5.51';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
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

