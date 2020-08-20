table 6151418 "Magento Setup Event Sub."
{
    // MAG2.05/MHA /20170714  CASE 283777 Object created
    // MAG2.07/MHA /20170830  CASE 286943 Added Options to field 1 "Type"
    // MAG2.08/MHA /20171016  CASE 292926 Removed "Setup Vat Bus. Posting Groups","Setup Vat Product Posting Groups" from field 1 "Type" and added new Options
    // MAG2.17/JDH /20181112  CASE 334163 Added Caption to Fields 1 and 15
    // MAG2.26/MHA /20200601  CASE 404580 Added Options to Field 1 "Type"; "Setup Categories", "Setup Brands"

    Caption = 'Magento Setup Event Subscription';
    DataClassification = CustomerContent;
    DrillDownPageID = "Magento Setup Event Subs.";
    LookupPageID = "Magento Setup Event Subs.";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            Description = 'MAG2.07,MAG2.08,MAG2.26';
            OptionCaption = 'DragDrop Picture,Magento Picture Url,,,,,,,Setup NpXml Templates,Setup Magento Tax Classes,,,Setup Magento Api Credentials,Setup Magento Websites,Setup Magento Customer Groups,Setup Payment Method Mapping,Setup Shipment Method Mapping,,,Setup Categories,,,Setup Brands';
            OptionMembers = "DragDrop Picture","Magento Picture Url",,,,,,,"Setup NpXml Templates","Setup Magento Tax Classes",,,"Setup Magento Api Credentials","Setup Magento Websites","Setup Magento Customer Groups","Setup Payment Method Mapping","Setup Shipment Method Mapping",,,"Setup Categories",,,"Setup Brands";
        }
        field(5; "Codeunit ID"; Integer)
        {
            BlankZero = true;
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if not LookupEventSubscription(EventSubscription) then
                    exit;

                "Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Function Name" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Codeunit ID" = 0 then begin
                    "Function Name" := '';
                    exit;
                end;

                SetEventSubscriptionFilter(EventSubscription);
                EventSubscription.SetRange("Subscriber Codeunit ID", "Codeunit ID");
                if "Function Name" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Function Name");
                EventSubscription.FindFirst;
            end;
        }
        field(10; "Function Name"; Text[80])
        {
            Caption = 'Function Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if not LookupEventSubscription(EventSubscription) then
                    exit;

                "Codeunit ID" := EventSubscription."Subscriber Codeunit ID";
                "Function Name" := EventSubscription."Subscriber Function";
            end;

            trigger OnValidate()
            var
                EventSubscription: Record "Event Subscription";
            begin
                if "Function Name" = '' then begin
                    "Codeunit ID" := 0;
                    exit;
                end;

                SetEventSubscriptionFilter(EventSubscription);
                EventSubscription.SetRange("Subscriber Codeunit ID", "Codeunit ID");
                if "Function Name" <> '' then
                    EventSubscription.SetRange("Subscriber Function", "Function Name");
                EventSubscription.FindFirst;
            end;
        }
        field(15; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(100; "Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup (AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
                                                             "Object ID" = FIELD("Codeunit ID")));
            Caption = 'Codeunit Name';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; Type, "Codeunit ID", "Function Name")
        {
        }
    }

    fieldgroups
    {
    }

    local procedure SetEventSubscriptionFilter(var EventSubscription: Record "Event Subscription"): Boolean
    begin
        Clear(EventSubscription);
        case Type of
            Type::"DragDrop Picture":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Picture Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnDragDropPicture');
                end;
            //-MAG2.08 [292926]
            Type::"Magento Picture Url":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Table);
                    EventSubscription.SetRange("Publisher Object ID", DATABASE::"Magento Picture");
                    EventSubscription.SetRange("Published Function", 'OnGetMagentoUrl');
                end;
            Type::"Setup NpXml Templates":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupNpXmlTemplates');
                end;
            //+MAG2.08 [292926]
            //-MAG2.07 [286943]
            Type::"Setup Magento Tax Classes":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoTaxClasses');
                end;
            //-MAG2.08 [292926]
            // Type::"Setup Vat Bus. Posting Groups":
            //  BEGIN
            //    EventSubscription.SETRANGE("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
            //    EventSubscription.SETRANGE("Publisher Object ID",CODEUNIT::"Magento Setup Mgt.");
            //    EventSubscription.SETRANGE("Published Function",'OnSetupVATBusinessPostingGroups');
            //  END;
            // Type::"Setup Vat Product Posting Groups":
            //  BEGIN
            //    EventSubscription.SETRANGE("Publisher Object Type",EventSubscription."Publisher Object Type"::Codeunit);
            //    EventSubscription.SETRANGE("Publisher Object ID",CODEUNIT::"Magento Setup Mgt.");
            //    EventSubscription.SETRANGE("Published Function",'OnSetupVATProductPostingGroups');
            //  END;
            //+MAG2.08 [292926]
            Type::"Setup Magento Api Credentials":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoCredentials');
                end;
            Type::"Setup Magento Websites":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoWebsites');
                end;
            Type::"Setup Magento Customer Groups":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoCustomerGroups');
                end;
            Type::"Setup Payment Method Mapping":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupPaymentMethodMapping');
                end;
            Type::"Setup Shipment Method Mapping":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupShipmentMethodMapping');
                end;
            //+MAG2.07 [286943]
            //-MAG2.26 [404580]
            Type::"Setup Categories":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupCategories');
                end;
            Type::"Setup Brands":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupBrands');
                end;
            //+MAG2.26 [404580]
            else
                exit(false);
        end;

        exit(true);
    end;

    local procedure LookupEventSubscription(var EventSubscription: Record "Event Subscription"): Boolean
    begin
        if not SetEventSubscriptionFilter(EventSubscription) then
            exit;

        exit(PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) = ACTION::LookupOK);
    end;
}

