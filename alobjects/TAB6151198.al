table 6151198 "NpCs Document"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Document';
    DataCaptionFields = "Document Type","Reference No.","Sell-to Customer Name";
    DrillDownPageID = "NpCs Document List";
    LookupPageID = "NpCs Document List";

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
            TableRelation = "Sales Header"."No." WHERE ("Document Type"=FIELD("Document Type"));

            trigger OnValidate()
            begin
                if "Reference No." = '' then
                  "Reference No." := "Document No.";
            end;
        }
        field(10;"Reference No.";Code[50])
        {
            Caption = 'Reference No.';
        }
        field(15;"Workflow Code";Code[20])
        {
            Caption = 'Workflow Code';
            TableRelation = "NpCs Workflow";

            trigger OnValidate()
            var
                NpCsWorkflow: Record "NpCs Workflow";
                NpCsStoreWorkflowRelation: Record "NpCs Store Workflow Relation";
            begin
                if "Workflow Code" = '' then
                  exit;

                TestField("To Store Code");
                NpCsStoreWorkflowRelation.Get("To Store Code","Workflow Code");

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
                "Delivery Print Template (POS)" := NpCsStoreWorkflowRelation."Delivery Print Template (POS)";
                "Delivery Print Template (S.)" := NpCsStoreWorkflowRelation."Delivery Print Template (S.)";

                NpCsWorkflow.Get("Workflow Code");
                "Processing Expiry Duration" := NpCsWorkflow."Processing Expiry Duration";
                "Delivery Expiry Days (Qty.)" := NpCsWorkflow."Delivery Expiry Days (Qty.)";
                "Archive on Delivery" := NpCsWorkflow."Archive on Delivery";
            end;
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

            trigger OnValidate()
            var
                NpCsStore: Record "NpCs Store";
            begin
                NpCsStore.Get("To Store Code");
                "Prepayment Account No." := NpCsStore."Prepayment Account No.";
            end;
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

            trigger OnValidate()
            begin
                "Processing updated at" := CurrentDateTime;
                "Processing updated by" := UserId;
            end;
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
        field(195;"Delivery Expiry Days (Qty.)";Integer)
        {
            Caption = 'Delivery Expiry Days (Qty.)';
            MinValue = 0;
        }
        field(200;"Delivery Status";Option)
        {
            Caption = 'Delivery Status';
            OptionCaption = ' ,Ready,Delivered,Expired';
            OptionMembers = " ",Ready,Delivered,Expired;

            trigger OnValidate()
            begin
                "Delivery updated at" := CurrentDateTime;
                "Delivery updated by" := UserId;
            end;
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

            trigger OnValidate()
            begin
                if "Reference No." = '' then
                  "Reference No." := "Document No.";
            end;
        }
        field(235;"Archive on Delivery";Boolean)
        {
            Caption = 'Archive on Delivery';
        }
        field(240;"Delivery Only (Non stock)";Boolean)
        {
            Caption = 'Delivery Only (Non stock)';
        }
        field(300;"Bill via";Option)
        {
            Caption = 'Bill via';
            OptionCaption = 'POS,Sales Document';
            OptionMembers = POS,"Sales Document";
        }
        field(305;"Delivery Print Template (POS)";Code[20])
        {
            Caption = 'Delivery Print Template (POS)';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
        }
        field(310;"Delivery Print Template (S.)";Code[20])
        {
            Caption = 'Delivery Template (Sales Document)';
            TableRelation = "RP Template Header" WHERE ("Table ID"=CONST(6151198));
        }
        field(1000;"Send Order Module";Code[20])
        {
            CalcFormula = Lookup("NpCs Workflow"."Send Order Module" WHERE (Code=FIELD("Workflow Code")));
            Caption = 'Send Order Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1005;"Order Status Module";Code[20])
        {
            CalcFormula = Lookup("NpCs Workflow"."Order Status Module" WHERE (Code=FIELD("Workflow Code")));
            Caption = 'Order Status Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(1010;"Post Processing Module";Code[20])
        {
            CalcFormula = Lookup("NpCs Workflow"."Post Processing Module" WHERE (Code=FIELD("Workflow Code")));
            Caption = 'Post Processing Module';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2000;"Sell-to Customer Name";Text[50])
        {
            CalcFormula = Lookup("Sales Header"."Sell-to Customer Name" WHERE ("Document Type"=CONST(Order),
                                                                               "No."=FIELD("Document No.")));
            Caption = 'Sell-to Customer Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2005;"Location Code";Code[10])
        {
            CalcFormula = Lookup("Sales Header"."Location Code" WHERE ("Document Type"=CONST(Order),
                                                                       "No."=FIELD("Document No.")));
            Caption = 'Location Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2010;"To Store Contact Name";Text[50])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Name" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2015;"To Store Contact Name 2";Text[50])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Name 2" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Name 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2020;"To Store Contact Address";Text[50])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Address" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Address';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2025;"To Store Contact Address 2";Text[50])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Address 2" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Address 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2030;"To Store Contact Post Code";Code[20])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Post Code" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Post Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2035;"To Store Contact City";Text[30])
        {
            CalcFormula = Lookup("NpCs Store"."Contact City" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact City';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2040;"To Store Contact Region Code";Code[10])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Country/Region Code" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Country/Region Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2045;"To Store Contact County";Text[30])
        {
            CalcFormula = Lookup("NpCs Store"."Contact County" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact County';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2050;"To Store Contact Phone No.";Text[30])
        {
            CalcFormula = Lookup("NpCs Store"."Contact Phone No." WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact Phone No.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(2055;"To Store Contact E-mail";Text[80])
        {
            CalcFormula = Lookup("NpCs Store"."Contact E-mail" WHERE (Code=FIELD("To Store Code")));
            Caption = 'To Store Contact E-mail';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
        key(Key2;"Document Type","Document No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        SalesHeader: Record "Sales Header";
        NpCsDocumentLogEntry: Record "NpCs Document Log Entry";
    begin
        if Type = Type::"Collect in Store" then begin
          if SalesHeader.Get("Document Type","Document No.") then
            SalesHeader.Delete(true);
        end;

        NpCsDocumentLogEntry.SetRange("Document Entry No.","Entry No.");
        NpCsDocumentLogEntry.DeleteAll;
    end;
}

