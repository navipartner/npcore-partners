table 6151418 "NPR Magento Setup Event Sub."
{
    Access = Internal;
    Caption = 'Magento Setup Event Subscription';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Magento Setup Event Subs.";
    LookupPageID = "NPR Magento Setup Event Subs.";

    fields
    {
        field(1; Type; Enum "NPR Mag. Setup Event Sub. Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
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
                "Function Name" := CopyStr(EventSubscription."Subscriber Function", 1, MaxStrLen("Function Name"));
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
                EventSubscription.FindFirst();
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
                "Function Name" := CopyStr(EventSubscription."Subscriber Function", 1, MaxStrLen("Function Name"));
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
                EventSubscription.FindFirst();
            end;
        }
        field(15; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(100; "Codeunit Name"; Text[50])
        {
            CalcFormula = Lookup(AllObj."Object Name" WHERE("Object Type" = CONST(Codeunit),
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

    local procedure SetEventSubscriptionFilter(var EventSubscription: Record "Event Subscription"): Boolean
    begin
        Clear(EventSubscription);
        case Type of
            Type::"DragDrop Picture":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Picture Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnDragDropPicture');
                end;
            Type::"Magento Picture Url":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Table);
                    EventSubscription.SetRange("Publisher Object ID", DATABASE::"NPR Magento Picture");
                    EventSubscription.SetRange("Published Function", 'OnGetMagentoUrl');
                end;
            Type::"Setup NpXml Templates":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupNpXmlTemplates');
                end;
            Type::"Setup Magento Tax Classes":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoTaxClasses');
                end;
            Type::"Setup Magento Api Credentials":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoCredentials');
                end;
            Type::"Setup Magento Websites":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoWebsites');
                end;
            Type::"Setup Magento Customer Groups":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupMagentoCustomerGroups');
                end;
            Type::"Setup Payment Method Mapping":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupPaymentMethodMapping');
                end;
            Type::"Setup Shipment Method Mapping":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupShipmentMethodMapping');
                end;
            Type::"Setup Categories":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupCategories');
                end;
            Type::"Setup Brands":
                begin
                    EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                    EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Magento Setup Mgt.");
                    EventSubscription.SetRange("Published Function", 'OnSetupBrands');
                end;
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
