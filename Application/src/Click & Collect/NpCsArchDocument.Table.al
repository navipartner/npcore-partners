table 6151202 "NPR NpCs Arch. Document"
{
    Caption = 'Collect Document';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NpCs Arch. Doc. List";
    LookupPageID = "NPR NpCs Arch. Doc. List";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Send to Store,Collect in Store';
            OptionMembers = "Send to Store","Collect in Store";
        }
        field(5; "Document Type"; Enum "NPR NpCs Document Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = IF ("Document Type" = FILTER(Quote | Order | Invoice | "Credit Memo" | "Blanket Order" | "Return Order")) "Sales Header"."No." WHERE("Document Type" = FIELD("Document Type"))
            ELSE
            IF ("Document Type" = CONST("Posted Invoice")) "Sales Invoice Header"
            ELSE
            IF ("Document Type" = CONST("Posted Credit Memo")) "Sales Cr.Memo Header";
        }
        field(10; "Reference No."; Code[50])
        {
            Caption = 'Reference No.';
            DataClassification = CustomerContent;
        }
        field(13; "Inserted at"; DateTime)
        {
            Caption = 'Inserted at';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(15; "Workflow Code"; Code[20])
        {
            Caption = 'Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow";
        }
        field(20; "Next Workflow Step"; Option)
        {
            Caption = 'Next Workflow Step';
            DataClassification = CustomerContent;
            OptionCaption = 'Send Order,Order Status,Post Processing';
            OptionMembers = "Send Order","Order Status","Post Processing";
        }
        field(25; "From Document Type"; Option)
        {
            Caption = 'From Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(27; "From Document No."; Code[20])
        {
            Caption = 'From Document No.';
            DataClassification = CustomerContent;
        }
        field(30; "From Store Code"; Code[20])
        {
            Caption = 'From Store Code';
            DataClassification = CustomerContent;
        }
        field(35; "Callback Data"; BLOB)
        {
            Caption = 'Callback Data';
            DataClassification = CustomerContent;
        }
        field(55; "To Document Type"; Option)
        {
            Caption = 'To Document Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order";
        }
        field(57; "To Document No."; Code[20])
        {
            Caption = 'To Document No.';
            DataClassification = CustomerContent;
        }
        field(60; "To Store Code"; Code[20])
        {
            Caption = 'To Store Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR NpCs Store";
        }
        field(65; "Opening Hour Set"; Code[20])
        {
            Caption = 'Opening Hour Set';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR NpCs Open. Hour Set";
        }
        field(95; "Processing Expiry Duration"; Duration)
        {
            Caption = 'Processing Expiry Duration';
            DataClassification = CustomerContent;
        }
        field(100; "Processing Status"; Option)
        {
            Caption = 'Processing Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Pending,Confirmed,Rejected,Expired';
            OptionMembers = " ",Pending,Confirmed,Rejected,Expired;
        }
        field(105; "Processing updated at"; DateTime)
        {
            Caption = 'Processing updated at';
            DataClassification = CustomerContent;
        }
        field(110; "Processing updated by"; Code[50])
        {
            Caption = 'Processing updated by';
            DataClassification = CustomerContent;
        }
        field(113; "Processing expires at"; DateTime)
        {
            Caption = 'Processing expires at';
            DataClassification = CustomerContent;
        }
        field(114; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(115; "Customer E-mail"; Text[80])
        {
            Caption = 'Customer E-mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(120; "Customer Phone No."; Text[30])
        {
            Caption = 'Customer Phone No.';
            DataClassification = CustomerContent;
        }
        field(125; "Send Notification from Store"; Boolean)
        {
            Caption = 'Send Notification from Store';
            DataClassification = CustomerContent;
        }
        field(130; "Notify Customer via E-mail"; Boolean)
        {
            Caption = 'Notify Customer via E-mail';
            DataClassification = CustomerContent;
        }
        field(135; "E-mail Template (Pending)"; Code[20])
        {
            Caption = 'E-mail Template (Pending)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(140; "E-mail Template (Confirmed)"; Code[20])
        {
            Caption = 'E-mail Template (Confirmed)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(145; "E-mail Template (Rejected)"; Code[20])
        {
            Caption = 'E-mail Template (Rejected)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(150; "E-mail Template (Expired)"; Code[20])
        {
            Caption = 'E-mail Template (Expired)';
            DataClassification = CustomerContent;
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(155; "Notify Customer via Sms"; Boolean)
        {
            Caption = 'Notify Customer via Sms';
            DataClassification = CustomerContent;
        }
        field(160; "Sms Template (Pending)"; Code[10])
        {
            Caption = 'Sms Template (Pending)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(165; "Sms Template (Confirmed)"; Code[10])
        {
            Caption = 'Sms Template (Confirmed)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(170; "Sms Template (Rejected)"; Code[10])
        {
            Caption = 'Sms Template (Rejected)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(175; "Sms Template (Expired)"; Code[10])
        {
            Caption = 'Sms Template (Expired)';
            DataClassification = CustomerContent;
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(195; "Delivery Expiry Duration"; Duration)
        {
            Caption = 'Delivery Expiry Duration';
            DataClassification = CustomerContent;
        }
        field(200; "Delivery Status"; Option)
        {
            Caption = 'Delivery Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Ready,Delivered,Expired';
            OptionMembers = " ",Ready,Delivered,Expired;
        }
        field(205; "Delivery updated at"; DateTime)
        {
            Caption = 'Delivery updated at';
            DataClassification = CustomerContent;
        }
        field(210; "Delivery updated by"; Code[50])
        {
            Caption = 'Delivery updated by';
            DataClassification = CustomerContent;
        }
        field(213; "Delivery expires at"; DateTime)
        {
            Caption = 'Delivery expires at';
            DataClassification = CustomerContent;
        }
        field(215; "Prepaid Amount"; Decimal)
        {
            Caption = 'Prepaid Amount';
            DataClassification = CustomerContent;
        }
        field(220; "Prepayment Account No."; Code[20])
        {
            Caption = 'Prepayment Account No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" WHERE("Direct Posting" = CONST(true));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(225; "Delivery Document Type"; Option)
        {
            Caption = 'Delivery Document Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Sales Shipment,Sales Invoice,Sales Return Receipt,Sales Credit Memo,POS Entry';
            OptionMembers = " ","Sales Shipment","Sales Invoice","Sales Return Receipt","Sales Credit Memo","POS Entry";
        }
        field(230; "Delivery Document No."; Code[20])
        {
            Caption = 'Delivery Document No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Delivery Document Type" = CONST("Sales Shipment")) "Sales Shipment Header"
            ELSE
            IF ("Delivery Document Type" = CONST("Sales Invoice")) "Sales Invoice Header"
            ELSE
            IF ("Delivery Document Type" = CONST("Sales Return Receipt")) "Return Receipt Header"
            ELSE
            IF ("Delivery Document Type" = CONST("Sales Credit Memo")) "Sales Cr.Memo Header"
            ELSE
            IF ("Delivery Document Type" = CONST("POS Entry")) "NPR POS Entry";
        }
        field(235; "Archive on Delivery"; Boolean)
        {
            Caption = 'Archive on Delivery';
            DataClassification = CustomerContent;
        }
        field(240; "Store Stock"; Boolean)
        {
            Caption = 'Store Stock';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            InitValue = true;
        }
        field(250; "Post on"; Option)
        {
            Caption = 'Post on';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            OptionCaption = 'Delivery,Processing';
            OptionMembers = Delivery,Processing;
        }
        field(290; "Processing Print Template"; Code[20])
        {
            Caption = 'Processing Print Template';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(300; "Bill via"; Option)
        {
            Caption = 'Bill via';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            OptionCaption = 'POS,Sales Document';
            OptionMembers = POS,"Sales Document";
        }
        field(305; "Delivery Print Template (POS)"; Code[20])
        {
            Caption = 'Delivery Print Template (POS)';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(310; "Delivery Print Template (S.)"; Code[20])
        {
            Caption = 'Delivery Template (Sales Document)';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(315; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "Salesperson/Purchaser";
        }
        field(2000; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
        field(2005; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(5000; "Archived at"; DateTime)
        {
            Caption = 'Archived at';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    trigger OnDelete()
    var
        NpCsArchDocumentLogEntry: Record "NPR NpCs Arch. Doc. Log Entry";
    begin
        NpCsArchDocumentLogEntry.SetRange("Document Entry No.", "Entry No.");
        NpCsArchDocumentLogEntry.DeleteAll();
    end;
}

