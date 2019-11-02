table 6150615 "POS Unit"
{
    // NPR5.29/AP/20170126 CASE 261728 Recreated ENU-captions
    // NPR5.30/AP/20170209 CASE 261728 Renamed field "Store Code" -> "POS Store Code"
    //                                 Added field 11 "Default POS Payment Bin"
    // NPR5.36/JDH /20171003 CASE ?????? someone added field Status
    // NPR5.37/TSA /20171024 CASE 293905 Added field Lock Timeout
    // NPR5.38/BR  /20171124 CASE 297087 Changed Initvalue of Status field to CLOSED
    // NPR5.45/MHA /20180803 CASE 323705 Added fields 300, 305, 310 to enable overload of Item Price functionality
    // NPR5.45/MHA /20180814 CASE 319706 Added field 200 Ean Box Sales Setup
    // NPR5.45/TJ  /20180809 CASE 323728 New field Kiosk Mode Unlock PIN
    // NPR5.45/MHA /20180820 CASE 321266 Added field 205 "POS Sales Workflow Set"
    // NPR5.48/MMV /20181026 CASE 318028 French certification
    // NPR5.49/TJ  /20181115 CASE 335739 New field "POS View Profile"
    // NPR5.49/TSA /20190311 CASE 348458 New field "EOD Managed by POS Unit"
    // NPR5.51/SARA/20190823 CASE 363578 New field 'SMS Profile'
    // NPR5.52/ALPO/20190923 CASE 365326 New field "POS Posting Profile" (Posting related fields moved to POS Posting Profiles from NP Retail Setup)
    // NPR5.52/SARA/20190924 CASE 368395 Delete field 'SMS Profile'(SMS profile move to POS End of Day Profile)
    // NPR5.52/MHA /20191016 CASE 371388 Field 400 "Global POS Sales Setup" moved from Np Retail Setup to POS Unit

    Caption = 'POS Unit';
    DataCaptionFields = "No.",Name;
    DrillDownPageID = "POS Unit List";
    LookupPageID = "POS Unit List";

    fields
    {
        field(1;"No.";Code[10])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2;Name;Text[50])
        {
            Caption = 'Name';
        }
        field(10;"POS Store Code";Code[10])
        {
            Caption = 'POS Store Code';
            TableRelation = "POS Store";
        }
        field(11;"Default POS Payment Bin";Code[10])
        {
            Caption = 'Default POS Payment Bin';
            TableRelation = "POS Payment Bin";
        }
        field(20;Status;Option)
        {
            Caption = 'Status';
            InitValue = CLOSED;
            OptionCaption = 'Open,Closed,End of Day';
            OptionMembers = OPEN,CLOSED,EOD;
        }
        field(30;"Global Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,1,1';
            Caption = 'Global Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Global Dimension 1 Code");
            end;
        }
        field(31;"Global Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,1,2';
            Caption = 'Global Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE ("Global Dimension No."=CONST(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Global Dimension 2 Code");
            end;
        }
        field(40;"Lock Timeout";Option)
        {
            Caption = 'Lock Timeout';
            OptionCaption = 'Never,30 Seconds,60 Seconds,90 Seconds,120 Seconds,600 Seconds';
            OptionMembers = NEVER,"30S","60S","90S","120S","600S";

            trigger OnValidate()
            var
                POSSetup: Record "POS Setup";
            begin
                POSSetup.Get ();
                if ("Lock Timeout" <> "Lock Timeout"::NEVER) then
                  POSSetup.TestField ("Lock POS Action Code");
            end;
        }
        field(50;"Kiosk Mode Unlock PIN";Text[30])
        {
            Caption = 'Kiosk Mode Unlock PIN';
            Description = 'NPR5.45';
        }
        field(200;"Ean Box Sales Setup";Code[20])
        {
            Caption = 'Ean Box Sales Setup';
            Description = 'NPR5.45';
            TableRelation = "Ean Box Setup" WHERE ("POS View"=CONST(Sale));
        }
        field(205;"POS Sales Workflow Set";Code[20])
        {
            Caption = 'POS Sales Workflow Set';
            Description = 'NPR5.45';
            TableRelation = "POS Sales Workflow Set";
        }
        field(300;"Item Price Codeunit ID";Integer)
        {
            BlankZero = true;
            Caption = 'Item Price Codeunit ID';
            Description = 'NPR5.45';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Item Price Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Item Price Function" := EventSubscription."Subscriber Function";
                //+NPR5.45 [323705]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                if "Item Price Codeunit ID" = 0 then begin
                  "Item Price Function" := '';
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID","Item Price Codeunit ID");
                if "Item Price Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Item Price Function");
                EventSubscription.FindFirst;
                //+NPR5.45 [323705]
            end;
        }
        field(305;"Item Price Codeunit Name";Text[30])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE ("Object Type"=CONST(Codeunit),
                                                             "Object ID"=FIELD("Item Price Codeunit ID")));
            Caption = 'Item Price Codeunit Name';
            Description = 'NPR5.45';
            Editable = false;
            FieldClass = FlowField;
        }
        field(310;"Item Price Function";Text[250])
        {
            Caption = 'Item Price Function';
            Description = 'NPR5.45';

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                if PAGE.RunModal(PAGE::"Event Subscriptions",EventSubscription) <> ACTION::LookupOK then
                  exit;

                "Item Price Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Item Price Function" := EventSubscription."Subscriber Function";
                //+NPR5.45 [323705]
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.45 [323705]
                if "Item Price Function" = '' then begin
                  "Item Price Codeunit ID" := 0;
                  exit;
                end;

                EventSubscription.SetRange("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID",GetPublisherCodeunitId());
                EventSubscription.SetRange("Published Function",GetPublisherFunction());
                EventSubscription.SetRange("Subscriber Codeunit ID","Item Price Codeunit ID");
                if "Item Price Function" <> '' then
                  EventSubscription.SetRange("Subscriber Function","Item Price Function");
                EventSubscription.FindFirst;
                //+NPR5.45 [323705]
            end;
        }
        field(400;"Global POS Sales Setup";Code[10])
        {
            Caption = 'Global POS Sales Setup';
            Description = 'NPR5.52';
            TableRelation = "NpGp POS Sales Setup";
        }
        field(500;"POS Audit Profile";Code[20])
        {
            Caption = 'POS Audit Profile';
            TableRelation = "POS Audit Profile";
        }
        field(501;"POS View Profile";Code[20])
        {
            Caption = 'POS View Profile';
            Description = 'NPR5.49';
            TableRelation = "POS View Profile";
        }
        field(510;"POS End of Day Profile";Code[20])
        {
            Caption = 'POS End of Day Profile';
            TableRelation = "POS End of Day Profile";
        }
        field(520;"POS Posting Profile";Code[20])
        {
            Caption = 'POS Posting Profile';
            Description = 'NPR5.52';
            TableRelation = "POS Posting Profile";
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateDimValueCode(FieldNumber,ShortcutDimCode);
        DimMgt.SaveDefaultDim(DATABASE::"POS Unit","No.",FieldNumber,ShortcutDimCode);
        Modify;
    end;

    local procedure GetPublisherCodeunitId(): Integer
    begin
        //-NPR5.45 [323705]
        exit(CODEUNIT::"POS Sales Price Calc. Mgt.");
        //+NPR5.45 [323705]
    end;

    local procedure GetPublisherFunction(): Text
    begin
        //-NPR5.45 [323705]
        exit('OnFindItemPrice');
        //+NPR5.45 [323705]
    end;
}

