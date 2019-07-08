table 6151202 "NpCs Arch. Document"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document';
    DrillDownPageID = "NpCs Arch. Document List";
    LookupPageID = "NpCs Arch. Document List";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(3;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Send to Store,Collect in Store';
            OptionMembers = "Send to Store","Collect in Store";
        }
        field(5;"Document Type";Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(7;"Document No.";Code[20])
        {
            Caption = 'Document No.';
        }
        field(10;"Reference No.";Code[50])
        {
            Caption = 'Reference No.';
        }
        field(15;"Workflow Code";Code[20])
        {
            Caption = 'Workflow Code';
            TableRelation = "NpCs Workflow";
        }
        field(20;"Next Workflow Step";Option)
        {
            Caption = 'Next Workflow Step';
            OptionCaption = 'Send Order,Order Status,Post Processing';
            OptionMembers = "Send Order","Order Status","Post Processing";
        }
        field(25;"From Document Type";Option)
        {
            Caption = 'From Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(27;"From Document No.";Code[20])
        {
            Caption = 'From Document No.';
        }
        field(30;"From Store Code";Code[20])
        {
            Caption = 'From Store Code';
        }
        field(35;"Callback Data";BLOB)
        {
            Caption = 'Callback Data';
        }
        field(55;"To Document Type";Option)
        {
            Caption = 'To Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(57;"To Document No.";Code[20])
        {
            Caption = 'To Document No.';
        }
        field(60;"To Store Code";Code[20])
        {
            Caption = 'To Store Code';
            TableRelation = "NpCs Store" WHERE ("Local Store"=CONST(false));
        }
        field(95;"Processing Expiry Duration";Duration)
        {
            Caption = 'Processing Expiry Duration';
        }
        field(100;"Processing Status";Option)
        {
            Caption = 'Processing Status';
            OptionCaption = ' ,Pending,Confirmed,Rejected,Expired';
            OptionMembers = " ",Pending,Confirmed,Rejected,Expired;
        }
        field(105;"Processing updated at";DateTime)
        {
            Caption = 'Processing updated at';
        }
        field(110;"Processing updated by";Code[50])
        {
            Caption = 'Processing updated by';
        }
        field(113;"Processing expires at";DateTime)
        {
            Caption = 'Processing expires at';
        }
        field(115;"Customer E-mail";Text[80])
        {
            Caption = 'Customer E-mail';
            ExtendedDatatype = EMail;
        }
        field(120;"Customer Phone No.";Text[30])
        {
            Caption = 'Customer Phone No.';
        }
        field(125;"Send Notification from Store";Boolean)
        {
            Caption = 'Send Notification from Store';
        }
        field(130;"Notify Customer via E-mail";Boolean)
        {
            Caption = 'Notify Customer via E-mail';
        }
        field(135;"E-mail Template (Pending)";Code[20])
        {
            Caption = 'E-mail Template (Pending)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(140;"E-mail Template (Confirmed)";Code[20])
        {
            Caption = 'E-mail Template (Confirmed)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(145;"E-mail Template (Rejected)";Code[20])
        {
            Caption = 'E-mail Template (Rejected)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(150;"E-mail Template (Expired)";Code[20])
        {
            Caption = 'E-mail Template (Expired)';
            TableRelation = "E-mail Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(155;"Notify Customer via Sms";Boolean)
        {
            Caption = 'Notify Customer via Sms';
        }
        field(160;"Sms Template (Pending)";Code[10])
        {
            Caption = 'Sms Template (Pending)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(165;"Sms Template (Confirmed)";Code[10])
        {
            Caption = 'Sms Template (Confirmed)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(170;"Sms Template (Rejected)";Code[10])
        {
            Caption = 'Sms Template (Rejected)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(175;"Sms Template (Expired)";Code[10])
        {
            Caption = 'Sms Template (Expired)';
            TableRelation = "SMS Template Header".Code WHERE ("Table No."=CONST(6151198));
        }
        field(195;"Delivery Expiry Duration";Duration)
        {
            Caption = 'Delivery Expiry Duration';
        }
        field(200;"Delivery Status";Option)
        {
            Caption = 'Delivery Status';
            OptionCaption = ' ,Ready,Delivered,Expired';
            OptionMembers = " ",Ready,Delivered,Expired;
        }
        field(205;"Delivery updated at";DateTime)
        {
            Caption = 'Delivery updated at';
        }
        field(210;"Delivery updated by";Code[50])
        {
            Caption = 'Delivery updated by';
        }
        field(213;"Delivery expires at";DateTime)
        {
            Caption = 'Delivery expires at';
        }
        field(215;"Prepaid Amount";Decimal)
        {
            Caption = 'Prepaid Amount';
        }
        field(220;"Prepayment Account No.";Code[20])
        {
            Caption = 'Prepayment Account No.';
            TableRelation = "G/L Account" WHERE ("Direct Posting"=CONST(true));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(225;"Delivery Document Type";Option)
        {
            Caption = 'Delivery Document Type';
            OptionCaption = ' ,Sales Shipment,Sales Invoice,Sales Return Receipt,Sales Credit Memo,POS Entry';
            OptionMembers = " ","Sales Shipment","Sales Invoice","Sales Return Receipt","Sales Credit Memo","POS Entry";
        }
        field(230;"Delivery Document No.";Code[20])
        {
            Caption = 'Delivery Document No.';
            TableRelation = IF ("Delivery Document Type"=CONST("Sales Shipment")) "Sales Shipment Header"
                            ELSE IF ("Delivery Document Type"=CONST("Sales Invoice")) "Sales Invoice Header"
                            ELSE IF ("Delivery Document Type"=CONST("Sales Return Receipt")) "Return Receipt Header"
                            ELSE IF ("Delivery Document Type"=CONST("Sales Credit Memo")) "Sales Cr.Memo Header"
                            ELSE IF ("Delivery Document Type"=CONST("POS Entry")) "POS Entry";
        }
        field(235;"Archive on Delivery";Boolean)
        {
            Caption = 'Archive on Delivery';
        }
        field(240;"Delivery Only (Non stock)";Boolean)
        {
            Caption = 'Delivery Only (Non stock)';
        }
        field(2005;"Location Code";Code[10])
        {
            Caption = 'Location Code';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        NpCsArchDocumentLogEntry: Record "NpCs Arch. Document Log Entry";
    begin
        NpCsArchDocumentLogEntry.SetRange("Document Entry No.","Entry No.");
        NpCsArchDocumentLogEntry.DeleteAll;
    end;
}

