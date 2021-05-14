table 6151198 "NPR NpCs Document"
{
    Caption = 'Collect Document';
    DataClassification = CustomerContent;
    DataCaptionFields = "Document Type", "Reference No.", "Sell-to Customer Name";
    DrillDownPageID = "NPR NpCs Document List";
    LookupPageID = "NPR NpCs Document List";

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

            trigger OnValidate()
            begin
                UpdateDocumentInfo();
            end;
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

            trigger OnValidate()
            begin
                UpdateDocumentInfo();
                if "Reference No." = '' then
                    "Reference No." := "Document No.";
            end;
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

            trigger OnValidate()
            var
                NpCsWorkflow: Record "NPR NpCs Workflow";
                NpCsStoreWorkflowRelation: Record "NPR NpCs Store Workflow Rel.";
            begin
                if "Workflow Code" = '' then
                    exit;

                TestField("To Store Code");
                NpCsStoreWorkflowRelation.Get("To Store Code", "Workflow Code");

                "Send Notification from Store" := NpCsStoreWorkflowRelation."Send Notification from Store";
                "Notify Customer via E-mail" := NpCsStoreWorkflowRelation."Notify Customer via E-mail";
                "E-mail Template (Pending)" := NpCsStoreWorkflowRelation."E-mail Template (Pending)";
                "E-mail Template (Confirmed)" := NpCsStoreWorkflowRelation."E-mail Template (Confirmed)";
                "E-mail Template (Rejected)" := NpCsStoreWorkflowRelation."E-mail Template (Rejected)";
                "E-mail Template (Expired)" := NpCsStoreWorkflowRelation."E-mail Template (Expired)";
                "Notify Customer via Sms" := NpCsStoreWorkflowRelation."Notify Customer via Sms";
                "Sms Template (Pending)" := NpCsStoreWorkflowRelation."Sms Template (Pending)";
                "Sms Template (Confirmed)" := NpCsStoreWorkflowRelation."Sms Template (Confirmed)";
                "Sms Template (Rejected)" := NpCsStoreWorkflowRelation."Sms Template (Rejected)";
                "Sms Template (Expired)" := NpCsStoreWorkflowRelation."Sms Template (Expired)";
                "Notify Store via E-mail" := NpCsStoreWorkflowRelation."Notify Store via E-mail";
                "Store E-mail Temp. (Pending)" := NpCsStoreWorkflowRelation."Store E-mail Temp. (Pending)";
                "Store E-mail Temp. (Expired)" := NpCsStoreWorkflowRelation."Store E-mail Temp. (Expired)";
                "Notify Store via Sms" := NpCsStoreWorkflowRelation."Notify Store via Sms";
                "Store Sms Template (Pending)" := NpCsStoreWorkflowRelation."Store Sms Template (Pending)";
                "Store Sms Template (Expired)" := NpCsStoreWorkflowRelation."Store Sms Template (Expired)";
                "Processing Print Template" := NpCsStoreWorkflowRelation."Processing Print Template";
                "Delivery Print Template (POS)" := NpCsStoreWorkflowRelation."Delivery Print Template (POS)";
                "Delivery Print Template (S.)" := NpCsStoreWorkflowRelation."Delivery Print Template (S.)";

                NpCsWorkflow.Get("Workflow Code");
                "Processing Expiry Duration" := NpCsWorkflow."Processing Expiry Duration";
                "Delivery Expiry Days (Qty.)" := NpCsWorkflow."Delivery Expiry Days (Qty.)";
                "Archive on Delivery" := NpCsWorkflow."Archive on Delivery";
                "Store Stock" := NpCsWorkflow."Store Stock";
                "Post on" := NpCsWorkflow."Post on";
                "Bill via" := NpCsWorkflow."Bill via";
            end;
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

            trigger OnValidate()
            var
                NpCsStore: Record "NPR NpCs Store";
            begin
                NpCsStore.Get("To Store Code");
                "Prepayment Account No." := NpCsStore."Prepayment Account No.";
                "Opening Hour Set" := NpCsStore."Opening Hour Set";
            end;
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

            trigger OnValidate()
            begin
                "Processing updated at" := CurrentDateTime;
                "Processing updated by" := UserId;
            end;
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
        field(195; "Delivery Expiry Days (Qty.)"; Integer)
        {
            Caption = 'Delivery Expiry Days (Qty.)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(200; "Delivery Status"; Option)
        {
            Caption = 'Delivery Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Ready,Delivered,Expired';
            OptionMembers = " ",Ready,Delivered,Expired;

            trigger OnValidate()
            begin
                "Delivery updated at" := CurrentDateTime;
                "Delivery updated by" := UserId;
            end;
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

            trigger OnValidate()
            begin
                if "Reference No." = '' then
                    "Reference No." := "Document No.";
            end;
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
        field(260; "Allow Partial Delivery"; Boolean)
        {
            Caption = 'Allow Partial Delivery';
            DataClassification = CustomerContent;
            Description = 'NPR5.55';
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
            OptionCaption = 'POS,Sales Document';
            OptionMembers = POS,"Sales Document";
        }
        field(305; "Delivery Print Template (POS)"; Code[20])
        {
            Caption = 'Delivery Print Template (POS)';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(310; "Delivery Print Template (S.)"; Code[20])
        {
            Caption = 'Delivery Template (Sales Document)';
            DataClassification = CustomerContent;
            TableRelation = "NPR RP Template Header" WHERE("Table ID" = CONST(6151198));
        }
        field(315; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.51';
            TableRelation = "Salesperson/Purchaser";
        }
        field(400; "Notify Store via E-mail"; Boolean)
        {
            Caption = 'Notify Store via E-mail';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(410; "Store E-mail Temp. (Pending)"; Code[20])
        {
            Caption = 'Store E-mail Template (Pending)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(420; "Store E-mail Temp. (Expired)"; Code[20])
        {
            Caption = 'Store E-mail Template (Expired)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR E-mail Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(430; "Notify Store via Sms"; Boolean)
        {
            Caption = 'Notify Store via Sms';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
        }
        field(440; "Store Sms Template (Pending)"; Code[10])
        {
            Caption = 'Store Sms Template (Pending)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(450; "Store Sms Template (Expired)"; Code[10])
        {
            Caption = 'Store Sms Template (Expired)';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';
            TableRelation = "NPR SMS Template Header".Code WHERE("Table No." = CONST(6151198));
        }
        field(1000; "Send Order Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpCs Workflow"."Send Order Module" WHERE(Code = FIELD("Workflow Code")));
            Caption = 'Send Order Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005; "Order Status Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpCs Workflow"."Order Status Module" WHERE(Code = FIELD("Workflow Code")));
            Caption = 'Order Status Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010; "Post Processing Module"; Code[20])
        {
            CalcFormula = Lookup("NPR NpCs Workflow"."Post Processing Module" WHERE(Code = FIELD("Workflow Code")));
            Caption = 'Post Processing Module';
            Editable = false;
            FieldClass = FlowField;
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
            Description = 'NPR5.51';
        }
        field(2010; "To Store Contact Name"; Text[100])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact Name" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2015; "To Store Contact Name 2"; Text[50])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact Name 2" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact Name 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2025; "To Store Contact Address 2"; Text[50])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact Address 2" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact Address 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2030; "To Store Contact Post Code"; Code[20])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact Post Code" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact Post Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2035; "To Store Contact City"; Text[30])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact City" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact City';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2040; "To Store Contact Region Code"; Code[10])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact Country/Region Code" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact Country/Region Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2045; "To Store Contact County"; Text[30])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact County" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact County';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2050; "To Store Contact Phone No."; Text[30])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact Phone No." WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact Phone No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2055; "To Store Contact E-mail"; Text[80])
        {
            CalcFormula = Lookup("NPR NpCs Store"."Contact E-mail" WHERE(Code = FIELD("To Store Code")));
            Caption = 'To Store Contact E-mail';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2060; "Ship-to Contact"; Text[100])
        {
            Caption = 'Ship-to Contact';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document Type", "Document No.")
        {
        }
        key(Key3; "Reference No.")
        {
        }
        key(Key4; "Processing expires at")
        {
        }
        key(Key5; "Delivery expires at")
        {
        }
    }

    trigger OnDelete()
    var
        SalesHeader: Record "Sales Header";
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
    begin
        if (Type = Type::"Collect in Store") and
          ("Document Type" in ["Document Type"::Quote, "Document Type"::Order, "Document Type"::Invoice, "Document Type"::"Credit Memo", "Document Type"::"Blanket Order", "Document Type"::"Return Order"])
        then begin
            if SalesHeader.Get("Document Type", "Document No.") then
                SalesHeader.Delete(true);
        end;

        NpCsDocumentLogEntry.SetRange("Document Entry No.", "Entry No.");
        NpCsDocumentLogEntry.DeleteAll();
    end;

    trigger OnInsert()
    begin
        "Inserted at" := CurrentDateTime;
    end;

    procedure GetLastLogMessage(): Text
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
    begin
        NpCsDocumentLogEntry.SetRange("Document Entry No.", "Entry No.");
        if NpCsDocumentLogEntry.FindLast() then
            exit(NpCsDocumentLogEntry."Log Message");
    end;

    procedure GetLastLogErrorMessage(): Text
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
    begin
        NpCsDocumentLogEntry.SetRange("Document Entry No.", "Entry No.");
        if NpCsDocumentLogEntry.FindLast() then
            exit(NpCsDocumentLogEntry.GetErrorMessage());
    end;

    local procedure UpdateDocumentInfo()
    var
        SalesHeader: Record "Sales Header";
    begin
        if SalesHeader.Get("Document Type", "Document No.") then begin
            "Sell-to Customer Name" := SalesHeader."Sell-to Customer Name";
            "Ship-to Contact" := SalesHeader."Ship-to Contact";
            "Location Code" := SalesHeader."Location Code";
        end;
    end;
}

