table 6150701 "POS Menu Button"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name
    // NPR5.32.11/TSA/20170614  CASE 280806 Added SetDefaultParamaters(), RefreshActionCode() functions to be used with refresh button
    // NPR5.32.11/VB /20170621  CASE 281618 Added "Blocking UI" field and business logic, and logic to pass tooltip and description information to JavaScript
    // NPR5.36/VB /20170912  CASE 289132 Added fields "Background Image Url" and "Caption Position" to support binding specific images to button backgrounds
    // NPR5.36/VB /20170926  CASE 291454 Fixing bug with non-action button configuration not showing up in UI
    // NPR5.37/VB /20171013  CASE 290485 Providing localization support for button captions (and other data)
    // NPR5.37/TSA /20171023 CASE 292656 Refactored RefreshActionCode() to retain current values on shared parameter names
    // NPR5.37/TSA /20171024 CASE 294214 Discontinued Action Type::ItemGroup - see case for replacement options
    // NPR5.38/BR  /20171122 CASE 295074 Added field Update Parameters
    // NPR5.39/VB  /20180130 CASE 303630 Fixing bug with moving hierarchies across other hierarchies
    // NPR5.39/MMV /20180212 CASE 299114 Rolling back previous parameter upgrade approach
    // NPR5.39/VB  /20180213 CASE 255773 Supporting Wysiwyg editor
    // NPR5.40/VB  /20180213 CASE 306347 Performance improvement due to parameters in BLOB and physical-table action discovery
    // NPR5.40/MMV /20180314 CASE 307453 Performance
    // NPR5.42/MMV /20180508 CASE 314128 Re-added support for button parameters when type <> Action
    // NPR5.42.01/MMV /20180627 CASE 320622 Filter correctly for button parameters
    // NPR5.43/VB  /20180611 CASE 314603 Implemented secure method behavior functionality.
    // NPR5.50/VB  /20180204 CASE 338666 When configuring actions for front end, parameters are not filtered if they already contain a filter on Table No.
    //                                   Support for Item, Customer, and Payment metadata in actions. This allows additional information to be passed to front-end workflows.
    // NPR5.54/TSA /20200221 CASE 392247 Added "Requires POS Type" to workflow content
    // NPR5.54/VB  /20200408 CASE 399736 Added "Show Plus/Minus Buttons" field.

    Caption = 'POS Menu Button';
    DataClassification = CustomerContent;
    DrillDownPageID = "POS Menu Buttons";
    LookupPageID = "POS Menu Buttons";

    fields
    {
        field(1; "Menu Code"; Code[20])
        {
            Caption = 'Menu Code';
            DataClassification = CustomerContent;
            TableRelation = "POS Menu";
        }
        field(2; ID; Integer)
        {
            Caption = 'ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Parent ID"; Integer)
        {
            Caption = 'Parent ID';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                //-NPR5.39 [255773]
                CalculateLevel;
                //+NPR5.39 [255773]
            end;
        }
        field(4; Ordinal; Integer)
        {
            Caption = 'Ordinal';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; Level; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(11; Caption; Text[250])
        {
            Caption = 'Caption';
            DataClassification = CustomerContent;
        }
        field(12; Tooltip; Text[250])
        {
            Caption = 'Tooltip';
            DataClassification = CustomerContent;
        }
        field(13; "Action Type"; Option)
        {
            Caption = 'Action Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Popup Menu,Action,Workflow,Item,,Customer,Payment Type';
            OptionMembers = Submenu,PopupMenu,"Action",Workflow,Item,ItemGroup_DISCONTINUED,Customer,PaymentType;

            trigger OnValidate()
            begin
                if "Action Type" <> xRec."Action Type" then begin
                    ClearActionSpecifics();
                end;
            end;
        }
        field(14; "Action Code"; Code[20])
        {
            Caption = 'Action Code';
            DataClassification = CustomerContent;
            TableRelation = IF ("Action Type" = CONST(PopupMenu)) "POS Menu"
            ELSE
            IF ("Action Type" = CONST(Item)) Item
            ELSE
            IF ("Action Type" = CONST(Action)) "POS Action" WHERE(Type = FILTER(Generic | Button),
                                                                                      Blocked = CONST(false))
            ELSE
            IF ("Action Type" = CONST(Customer)) Customer
            ELSE
            IF ("Action Type" = CONST(PaymentType)) "Payment Type POS";

            trigger OnLookup()
            begin
                //-NPR5.40 [306347]
                LookupActionCode();
                //+NPR5.40 [306347]
            end;

            trigger OnValidate()
            begin
                AssignCaption();
                AssignActionSpecifics();
                CopyParameters();
            end;
        }
        field(15; "Data Source Name"; Code[50])
        {
            Caption = 'Data Source Name';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TempDataSource: Record "POS Data Source (Discovery)";
            begin
                TempDataSource.LookupDataSource("Data Source Name");
            end;
        }
        field(19; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(21; "Background Color"; Text[30])
        {
            Caption = 'Background Color';
            DataClassification = CustomerContent;

            trigger OnLookup()
            begin
                LookupBackgroundColor();
            end;
        }
        field(22; "Foreground Color"; Text[30])
        {
            Caption = 'Foreground Color';
            DataClassification = CustomerContent;
        }
        field(23; "Icon Class"; Text[30])
        {
            Caption = 'Icon Class';
            DataClassification = CustomerContent;
        }
        field(24; "Custom Class Attribute"; Text[30])
        {
            Caption = 'Custom Class Attribute';
            DataClassification = CustomerContent;
        }
        field(25; Bold; Boolean)
        {
            Caption = 'Bold';
            DataClassification = CustomerContent;
        }
        field(26; "Font Size"; Option)
        {
            Caption = 'Font Size';
            DataClassification = CustomerContent;
            InitValue = Normal;
            OptionCaption = 'Extra Small,Small,Normal,Medium,Large,Extra Large';
            OptionMembers = XSmall,Small,Normal,Medium,Large,XLarge;
        }
        field(27; "Position X"; Integer)
        {
            BlankZero = true;
            Caption = 'Position X';
            DataClassification = CustomerContent;
        }
        field(28; "Position Y"; Integer)
        {
            BlankZero = true;
            Caption = 'Position Y';
            DataClassification = CustomerContent;
        }
        field(29; Enabled; Option)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            OptionCaption = 'Yes,Auto,No';
            OptionMembers = Yes,Auto,No;

            trigger OnValidate()
            begin
                HandleEnabled();
            end;
        }
        field(30; "Blocking UI"; Boolean)
        {
            Caption = 'Blocking UI';
            DataClassification = CustomerContent;
        }
        field(31; "Background Image Url"; Text[250])
        {
            Caption = 'Background Image Url';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
        }
        field(32; "Caption Position"; Option)
        {
            Caption = 'Caption Position';
            DataClassification = CustomerContent;
            Description = 'NPR5.36';
            OptionCaption = 'Center,Top,Bottom';
            OptionMembers = Center,Top,Bottom;
        }
        field(33; "Secure Method Code"; Code[10])
        {
            Caption = 'Secure Method Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.43';
            TableRelation = "POS Secure Method";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                SecureMethodTmp: Record "POS Secure Method" temporary;
            begin
                //-NPR5.43 [314603]
                if ("Secure Method Code" = '') then
                    exit;

                SecureMethodTmp.RunDiscovery();
                SecureMethodTmp.Get("Secure Method Code");
                //+NPR5.43 [314603]
            end;
        }
        field(34; "Show Plus/Minus Buttons"; Boolean)
        {
            Caption = 'Show Plus/Minus Buttons';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';

            trigger OnValidate()
            begin
                //-NPR5.54 [399736]
                if "Show Plus/Minus Buttons" then
                    TestField("Action Type", "Action Type"::Item);
                //+NPR5.54 [399736]
            end;
        }
        field(41; "Register Type"; Code[10])
        {
            Caption = 'Cash Register Type';
            DataClassification = CustomerContent;
            TableRelation = "Register Types";
        }
        field(42; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = Register;
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(44; "Available on Desktop"; Boolean)
        {
            Caption = 'Available on Desktop';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(45; "Available in App"; Boolean)
        {
            Caption = 'Available in App';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(Key1; "Menu Code", ID)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        HandleDescendantsOnDelete();
        RearrangeOrdinalsAfterDelete();
        //-NPR5.39 [255773]
        UnattendedDelete := false;
        //+NPR5.39 [255773]
        //-NPR5.40 [306347]
        ClearParameters();
        //+NPR5.40 [306347]
    end;

    trigger OnInsert()
    begin
        CalculateID();
        CalculateOrdinal();
        CalculatePath();
    end;

    var
        Text001: Label 'This menu button has descendalts. What do you want to do with them?';
        Text002: Label 'Unindent one level,Delete';
        POSActionMgt: Codeunit "POS Action Management";
        UnattendedDelete: Boolean;

    local procedure AssignCaption()
    begin
        if ("Action Code" = xRec."Action Code") or (Caption <> '') then
            exit;

        case "Action Type" of
            "Action Type"::Item:
                AssignCaptionForItem();
            "Action Type"::PaymentType:
                AssignCaptionForPaymentType();
            "Action Type"::Customer:
                AssignCaptionForCustomer();
        end;
    end;

    local procedure AssignCaptionForItem()
    var
        Item: Record Item;
    begin
        if Item.Get("Action Code") then begin
            Caption := Item.Description;
        end;
    end;

    local procedure AssignCaptionForPaymentType()
    var
        PaymentType: Record "Payment Type POS";
    begin
        PaymentType.SetRange("No.", "Action Code");
        if PaymentType.FindFirst then begin
            Caption := PaymentType.Description;
        end;
    end;

    local procedure AssignCaptionForCustomer()
    var
        Customer: Record Customer;
    begin
        if Customer.Get("Action Code") then begin
            Caption := Customer.Name;
        end;
    end;

    local procedure AssignActionSpecifics()
    var
        POSAction: Record "POS Action";
    begin
        if ("Action Type" = "Action Type"::Action) then begin
            if POSAction.Get("Action Code") then begin
                if POSAction."Bound to DataSource" then
                    Enabled := Enabled::Auto;
                "Data Source Name" := POSAction."Data Source Name";
                //-NPR5.36 [281618]
                "Blocking UI" := POSAction."Blocking UI";
                if (POSAction.Tooltip <> '') and (Tooltip = '') then
                    Tooltip := POSAction.Tooltip;
                //+NPR5.36 [281618]
                //-NPR5.43 [314603]
                if (POSAction."Secure Method Code" <> '') and ("Secure Method Code" = '') then
                    "Secure Method Code" := POSAction."Secure Method Code";
                //+NPR5.43 [314603]
            end else begin
                if "Action Code" = '' then begin
                    ClearActionSpecifics();
                end;
            end;
        end;
    end;

    local procedure ClearActionSpecifics()
    begin
        Clear("Action Code");
        Clear("Data Source Name");
        Clear(Enabled);
        //-NPR5.32.11 [281618]
        Clear("Blocking UI");
        Clear(Tooltip);
        //+NPR5.32.11 [281618]
        //-NPR5.40 [306347]
        ClearParameters();
        //+NPR5.40 [306347]
    end;

    local procedure ClearParameters()
    var
        ParamMgt: Codeunit "POS Action Parameter Mgt.";
    begin
        //-NPR5.40 [306347]
        ParamMgt.ClearParametersForRecord(RecordId, 0);
        //+NPR5.40 [306347]
    end;

    local procedure CopyParameters()
    var
        ParamMgt: Codeunit "POS Action Parameter Mgt.";
    begin
        if "Action Code" = xRec."Action Code" then
            exit;

        //-NPR5.40 [306347]
        //SetDefaultParameters();
        ClearParameters();
        case "Action Type" of
            "Action Type"::Action:
                ParamMgt.CopyFromActionToMenuButton("Action Code", Rec);
            "Action Type"::PopupMenu:
                SetupPopupSizeParameters();
        end;
        //+NPR5.40 [306347]
    end;

    local procedure LookupActionCode()
    var
        Customer: Record Customer;
        Item: Record Item;
        PaymentType: Record "Payment Type POS";
        POSMenu: Record "POS Menu";
        CustomerList: Page "Customer List";
        ItemList: Page "Item List";
        PaymentTypes: Page "Payment Type - Register";
        POSMenus: Page "POS Menus";
    begin
        //-NPR5.40 [306347]
        case "Action Type" of
            "Action Type"::Action:
                if POSActionMgt.LookupAction("Action Code") then
                    Validate("Action Code");
            "Action Type"::Customer:
                begin
                    if Customer.Get("Action Code") then
                        CustomerList.SetRecord(Customer);
                    CustomerList.LookupMode := true;
                    if CustomerList.RunModal() = ACTION::LookupOK then begin
                        CustomerList.GetRecord(Customer);
                        Validate("Action Code", Customer."No.");
                    end;
                end;
            "Action Type"::Item:
                begin
                    if Item.Get("Action Code") then
                        ItemList.SetRecord(Item);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal() = ACTION::LookupOK then begin
                        ItemList.GetRecord(Item);
                        Validate("Action Code", Item."No.");
                    end;
                end;
            "Action Type"::PaymentType:
                begin
                    PaymentType.SetRange("No.", "Action Code");
                    if PaymentType.Find() then
                        PaymentTypes.SetRecord(PaymentType);
                    PaymentTypes.LookupMode := true;
                    if PaymentTypes.RunModal() = ACTION::LookupOK then begin
                        PaymentTypes.GetRecord(PaymentType);
                        Validate("Action Code", PaymentType."No.");
                    end;
                end;
            "Action Type"::PopupMenu:
                begin
                    if POSMenu.Get("Action Code") then
                        POSMenus.SetRecord(POSMenu);
                    POSMenus.LookupMode := true;
                    if POSMenus.RunModal() = ACTION::LookupOK then begin
                        POSMenus.GetRecord(POSMenu);
                        Validate("Action Code", POSMenu.Code);
                    end;
                end;
        end;
        //+NPR5.40 [306347]
    end;

    local procedure SetupPopupSizeParameters()
    var
        ParamValue: Record "POS Parameter Value";
    begin
        //-NPR5.40 [306347]
        ParamValue.InitForMenuButton(Rec);
        ParamValue.Name := 'Columns';
        ParamValue."Data Type" := ParamValue."Data Type"::Integer;
        ParamValue.Value := Format(5);
        ParamValue.Insert;

        ParamValue.InitForMenuButton(Rec);
        ParamValue.Name := 'Rows';
        ParamValue."Data Type" := ParamValue."Data Type"::Integer;
        ParamValue.Value := Format(6);
        ParamValue.Insert;
        //+NPR5.40 [306347]
    end;

    procedure RefreshParameters()
    var
        ParamMgt: Codeunit "POS Action Parameter Mgt.";
        ParColumns: Record "POS Parameter Value";
        ParRows: Record "POS Parameter Value";
        ParamValue: Record "POS Parameter Value";
        ParColumnsKnown: Boolean;
        ParRowsKnown: Boolean;
    begin
        //-NPR5.40 [306347]
        case "Action Type" of
            "Action Type"::Action:
                ParamMgt.RefreshParameters(RecordId, "Menu Code", ID, "Action Code");
            "Action Type"::PopupMenu:
                begin
                    ParColumnsKnown := ParColumns.GetParameter(RecordId, ID, 'Columns');
                    ParRowsKnown := ParRows.GetParameter(RecordId, ID, 'Rows');
                    ParamMgt.ClearParametersForRecord(RecordId, ID);
                    SetupPopupSizeParameters();
                    if ParColumnsKnown then begin
                        ParamValue := ParColumns;
                        ParamValue.Find();
                        ParamValue.Value := ParColumns.Value;
                        ParamValue.Modify;
                    end;
                    if ParRowsKnown then begin
                        ParamValue := ParRows;
                        ParamValue.Find();
                        ParamValue.Value := ParRows.Value;
                        ParamValue.Modify;
                    end;
                end;
        end;
        //+NPR5.40 [306347]
    end;

    procedure RefreshParametersRequired(): Boolean
    var
        ParamMgt: Codeunit "POS Action Parameter Mgt.";
    begin
        //-NPR5.40 [306347]
        if ("Action Type" <> "Action Type"::Action) then
            exit(false)
        else
            exit(ParamMgt.RefreshParametersRequired(RecordId, "Menu Code", ID, "Action Code"));
        //+NPR5.40 [306347]
    end;

    procedure GetAction(var ActionOut: DotNet npNetAction; POSSession: Codeunit "POS Session"; Source: Text; var POSParameterValue: Record "POS Parameter Value")
    var
        ActionMgt: Codeunit "POS Action Management";
        ErrorText: Text;
        POSAction: Record "POS Action";
    begin
        case "Action Type" of
            "Action Type"::Action:
                GetWorkflowAction(ActionOut, POSSession);
            "Action Type"::Item:
                GetItemAction(ActionOut);
            "Action Type"::PopupMenu:
                GetMenuAction(ActionOut);
            "Action Type"::PaymentType:
                GetPaymentAction(ActionOut);
            "Action Type"::Customer:
                GetCustomerAction(ActionOut);
        end;
        if not IsNull(ActionOut) then begin
            //-NPR5.42 [314128]
            //StoreButtonParameters(ActionOut,POSParameterValue,POSActionParameter);
            StoreButtonParameters(ActionOut, POSParameterValue);
            //+NPR5.42 [314128]
            StoreDataSource(ActionOut);

            //-NPR5.54 [392247]
            // StoreActionOtherConfiguration(ActionOut);
            StoreActionOtherConfiguration(ActionOut, POSSession);
            //+NPR5.54 [392247]

            ActionMgt.IsValidActionConfiguration(POSSession, ActionOut, Source, ErrorText, true);

        end;
    end;

    local procedure GetWorkflowAction(var ActionOut: DotNet npNetAction; POSSession: Codeunit "POS Session")
    var
        POSAction: Record "POS Action" temporary;
        WorkflowAction: DotNet npNetWorkflowAction;
        WorkflowObj: DotNet npNetWorkflow;
        StreamReader: DotNet npNetStreamReader;
        "Object": DotNet npNetObject;
        InStr: InStream;
        Calculated: Boolean;
    begin
        with POSAction do begin
            WorkflowAction := WorkflowAction.WorkflowAction();
            //-NPR5.40 [306347]
            //  IF GET("Action Code") THEN BEGIN
            //    CALCFIELDS(Workflow);
            if POSSession.RetrieveSessionAction("Action Code", POSAction) then begin
                if Workflow.HasValue then begin
                    //+NPR5.40 [306347]
                    Workflow.CreateInStream(InStr);
                    StreamReader := StreamReader.StreamReader(InStr);
                    WorkflowAction.Workflow := WorkflowObj.FromJsonString(StreamReader.ReadToEnd(), GetDotNetType(WorkflowObj));
                    if "Bound to DataSource" then
                        WorkflowAction.Content.Add('DataBinding', true);
                    if "Custom JavaScript Logic".HasValue then begin
                        GetCustomJavaScriptLogic(Object);
                        WorkflowAction.Content.Add('CustomJavaScript', Object);
                    end;
                    //-NPR5.32.11 [281618]
                    if Description <> '' then
                        WorkflowAction.Content.Add('Description', Description);
                    //+NPR5.32.11 [281618]
                    //-NPR5.40 [306347]
                    //    END ELSE BEGIN
                    Calculated := true;
                end;
            end;
            if not Calculated then begin
                //+NPR5.40 [306347]
                WorkflowAction.Workflow := WorkflowObj.FromJsonString('{}', GetDotNetType(WorkflowObj));
                WorkflowAction.Workflow.Name := Code;
            end;

            ActionOut := WorkflowAction;
        end;
    end;

    local procedure GetItemAction(var ActionOut: DotNet npNetAction)
    var
        ItemAction: DotNet npNetItemAction;
        Metadata: DotNet npNetDictionary_Of_T_U;
    begin
        ActionOut := ItemAction.ItemAction("Action Code");
        //-NPR5.50 [338666]
        Metadata := Metadata.Dictionary();
        OnRetrieveItemMetadata(Metadata);
        ActionOut.Content.Add('Metadata', Metadata);
        //+NPR5.50 [338666]

        //-NPR5.54 [399736]
        if "Show Plus/Minus Buttons" then
            ActionOut.Content.Add('ShowPlusMinus', true);
        //+NPR5.54 [399736]
    end;

    local procedure GetMenuAction(var ActionOut: DotNet npNetAction)
    var
        MenuAction: DotNet npNetMenuAction;
    begin
        MenuAction := MenuAction.MenuAction();
        MenuAction.OpenAsPopup := true;
        MenuAction.MenuId := "Action Code";
        ActionOut := MenuAction;
    end;

    local procedure GetPaymentAction(var ActionOut: DotNet npNetAction)
    var
        PaymentAction: DotNet npNetPaymentAction;
        Metadata: DotNet npNetDictionary_Of_T_U;
    begin
        ActionOut := PaymentAction.PaymentAction("Action Code");
        //-NPR5.50 [338666]
        Metadata := Metadata.Dictionary();
        OnRetrievePaymentMetadata(Metadata);
        ActionOut.Content.Add('Metadata', Metadata);
        //+NPR5.50 [338666]
    end;

    local procedure GetCustomerAction(var ActionOut: DotNet npNetAction)
    var
        CustomerAction: DotNet npNetCustomerAction;
        Metadata: DotNet npNetDictionary_Of_T_U;
    begin
        ActionOut := CustomerAction.CustomerAction("Action Code");
        //-NPR5.50 [338666]
        Metadata := Metadata.Dictionary();
        OnRetrieveCustomerMetadata(Metadata);
        ActionOut.Content.Add('Metadata', Metadata);
        //+NPR5.50 [338666]
    end;

    local procedure HandleEnabled()
    var
        POSAction: Record "POS Action";
    begin
        if Enabled = Enabled::Auto then begin
            TestField("Action Type", "Action Type"::Action);
            POSAction.Get("Action Code");
            POSAction.TestField("Bound to DataSource");
        end;
    end;

    local procedure StoreButtonParameters(ActionIn: DotNet npNetAction; var POSParameterValue: Record "POS Parameter Value" temporary)
    begin
        //-NPR5.42 [314128]
        // POSActionParameter.SETRANGE("POS Action Code", "Action Code");
        // IF POSActionParameter.FINDSET THEN REPEAT
        //  IF POSParameterValue.GET(DATABASE::"POS Menu Button", "Menu Code", ID, RECORDID, POSActionParameter.Name) THEN
        //    POSParameterValue.AddParameterToAction(ActionIn);
        // UNTIL POSActionParameter.NEXT = 0;

        //-NPR5.50 [338666]
        if not POSParameterValue.GetParamFilterIndicator() then begin
            //+NPR5.50 [338666]

            POSParameterValue.SetRange("Table No.", DATABASE::"POS Menu Button");
            POSParameterValue.SetRange(Code, "Menu Code");
            //-NPR5.42.01 [320622]
            POSParameterValue.SetRange("Record ID", RecordId);
            //+NPR5.42.01 [320622]
            POSParameterValue.SetRange(ID, ID);

            //-NPR5.50 [338666]
        end;
        //+NPR5.50 [338666]

        if POSParameterValue.FindSet then
            repeat
                POSParameterValue.AddParameterToAction(ActionIn);
            until POSParameterValue.Next = 0;
        //+NPR5.42 [314128]
    end;

    local procedure StoreActionOtherConfiguration(ActionIn: DotNet npNetAction; POSSession: Codeunit "POS Session")
    var
        TempParam: Record "POS Parameter Value" temporary;
        POSAction: Record "POS Action";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        //-NPR5.36 [281618]
        if "Blocking UI" then
            ActionIn.Content.Add('Blocking', true);
        //+NPR5.36 [281618]

        //-NPR5.54 [392247]
        if (not POSSession.RetrieveSessionAction("Action Code", POSAction)) then
            exit;

        ActionIn.Content.Add('requirePosUnitType', Format(POSAction."Requires POS Type", 0, 9));
        //+NPR5.54 [392247]
    end;

    local procedure StoreDataSource(ActionIn: DotNet npNetAction)
    begin
        if "Data Source Name" <> '' then
            ActionIn.Content.Add('dataSource', "Data Source Name");
    end;

    procedure StoreButtonConfiguration(MenuButtonObj: DotNet npNetMenuButton)
    begin
        //-NPR5.36 [291454]
        if Tooltip <> '' then
            //-290485 [290485]
            //  MenuButtonObj.Tooltip := Tooltip;
            MenuButtonObj.Tooltip := GetLocalizedCaption(FieldNo(Tooltip));
        //+290485 [290485]
        if "Background Image Url" <> '' then begin
            MenuButtonObj.Content.Add('BackgroundImageUrl', "Background Image Url");
            MenuButtonObj.Content.Add('CaptionPosition', "Caption Position");
        end;
        //+NPR5.36 [291454]
        //-NPR5.43 [314603]
        if "Secure Method Code" <> '' then
            MenuButtonObj.Content.Add('SecureMethod', "Secure Method Code");
        //+NPR5.43 [314603]
    end;

    procedure SetSortOrderAndBaseMenuFilter(MenuCode: Code[20])
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Menu Code", Ordinal);
        Rec.SetRange("Menu Code", MenuCode);
    end;

    procedure FilterSubtree(MenuButton: Record "POS Menu Button"; IncludingThis: Boolean)
    var
        This: Text;
    begin
        if IncludingThis then
            This := MenuButton.Path + '|';
        Rec.SetFilter(Path, StrSubstNo('%2%1.*', MenuButton.Path, This));
    end;

    procedure IndentAllowed(): Boolean
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        if MenuButton.Next(-1) = 0 then
            exit(false)
        else
            exit(MenuButton.Level >= Level);
    end;

    procedure UnIndentAllowed(): Boolean
    var
        MenuButton: Record "POS Menu Button";
    begin
        exit(Level > 0);
    end;

    procedure MoveUpAllowed(): Boolean
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        //-NPR5.39 [303630]
        //EXIT(MenuButton.FindSibling('<'));
        exit(MenuButton.FindTarget('<'));
        //+NPR5.39
    end;

    procedure MoveDownAllowed(): Boolean
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        //-NPR5.39 [303630]
        //EXIT(MenuButton.FindSibling('>'));
        exit(MenuButton.FindTarget('>'));
        //+NPR5.39
    end;

    procedure ActionIsEditable(): Boolean
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton.SetRange("Parent ID", ID);
        exit(MenuButton.IsEmpty);
    end;

    procedure InsertRow()
    var
        MenuButton: Record "POS Menu Button";
        TempMenuButton: Record "POS Menu Button" temporary;
        NextOrdinal: Integer;
    begin
        NextOrdinal := xRec.Ordinal;

        MenuButton.SetSortOrderAndBaseMenuFilter(xRec."Menu Code");
        MenuButton.SetFilter(Ordinal, '>=%1', xRec.Ordinal);
        if MenuButton.FindSet() then
            repeat
                NextOrdinal += 1;
                TempMenuButton := MenuButton;
                TempMenuButton.Ordinal := NextOrdinal;
                TempMenuButton.Insert();
            until MenuButton.Next() = 0;

        if TempMenuButton.FindSet() then
            repeat
                MenuButton := TempMenuButton;
                MenuButton.Modify();
            until TempMenuButton.Next = 0;

        Init();
        Ordinal := xRec.Ordinal;
        "Parent ID" := xRec."Parent ID";
        Level := xRec.Level;
        CalculateID();
    end;

    procedure Indent()
    var
        MenuButton: Record "POS Menu Button";
        MenuButton2: Record "POS Menu Button";
    begin
        if not IndentAllowed() then
            exit;

        Level := Level + 1;

        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton.SetFilter(Ordinal, '<%1', Ordinal);
        MenuButton.SetRange(Level, Level - 1);
        MenuButton := Rec;
        MenuButton.Find('<');
        MenuButton2 := Rec;

        "Parent ID" := MenuButton.ID;
        CalculatePath();
        Modify();

        MenuButton.Get("Menu Code", "Parent ID");
        MenuButton."Action Type" := "Action Type"::Submenu;
        MenuButton."Action Code" := '';
        MenuButton.Modify();

        MenuButton.Reset();
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton.Ascending(false);
        MenuButton.FilterSubtree(MenuButton2, false);
        if MenuButton.FindSet(true) then
            repeat
                MenuButton.Level += 1;
                MenuButton.CalculatePath();
                MenuButton.Modify();
            until MenuButton.Next = 0;
    end;

    procedure UnIndent()
    var
        MenuButton: Record "POS Menu Button";
        MenuButton2: Record "POS Menu Button";
    begin
        if not UnIndentAllowed() then
            exit;

        MenuButton.Get("Menu Code", "Parent ID");
        MenuButton2 := Rec;

        Level := Level - 1;
        "Parent ID" := MenuButton."Parent ID";
        CalculatePath();
        Modify();

        MenuButton.Reset();
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton.FilterSubtree(MenuButton2, false);
        if MenuButton.FindSet(true) then
            repeat
                MenuButton.Level -= 1;
                MenuButton.CalculatePath();
                MenuButton.Modify();
            until MenuButton.Next = 0;
    end;

    procedure MoveUp()
    var
        CopyRec: Record "POS Menu Button";
        MenuButton: Record "POS Menu Button";
        TempMoveUp: Record "POS Menu Button" temporary;
        TempMoveDown: Record "POS Menu Button" temporary;
    begin
        if not MoveUpAllowed() then
            exit;

        CopyRec := Rec;

        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        //-NPR5.39 [303630]
        //IF NOT MenuButton.FindSibling('<') THEN
        //  EXIT;
        //
        //Rec.CopyHierarchy(TempMoveUp,TRUE);
        //MenuButton.CopyHierarchy(TempMoveDown,TRUE);
        //SwitchHierarchies(TempMoveUp,TempMoveDown,-1);

        if not MenuButton.FindTarget('<') then
            exit;
        SwitchNodes(Rec, MenuButton);
        //+NPR5.39
        MenuButton := CopyRec;
        MenuButton.Reset();
        MenuButton.Find();
        Rec := MenuButton;
    end;

    procedure MoveDown()
    var
        CopyRec: Record "POS Menu Button";
        MenuButton: Record "POS Menu Button";
        TempMoveUp: Record "POS Menu Button" temporary;
        TempMoveDown: Record "POS Menu Button" temporary;
    begin
        if not MoveDownAllowed() then
            exit;

        CopyRec := Rec;

        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;

        //-NPR5.39 [303630]
        //IF NOT MenuButton.FindSibling('>') THEN
        //  EXIT;
        //
        //Rec.CopyHierarchy(TempMoveDown,TRUE);
        //MenuButton.CopyHierarchy(TempMoveUp,MenuButton."Parent ID" = "Parent ID");
        //SwitchHierarchies(TempMoveUp,TempMoveDown,1);

        if not MenuButton.FindTarget('>') then
            exit;
        SwitchNodes(Rec, MenuButton);
        //+NPR5.39

        MenuButton := CopyRec;
        MenuButton.Reset();
        MenuButton.Find();
        Rec := MenuButton;
    end;

    procedure FindTarget(Direction: Code[10]): Boolean
    var
        MenuButton: Record "POS Menu Button";
        MenuButtonSibling: Record "POS Menu Button";
    begin
        MenuButton := Rec;

        SetSortOrderAndBaseMenuFilter("Menu Code");
        SetFilter(Level, '%1|%2', Level, Level - 1);
        if not Find(Direction) then
            exit(false);

        if MenuButton."Parent ID" = "Parent ID" then
            exit(true);

        // Crossing hierarchy boundary
        if not Get("Menu Code", MenuButton."Parent ID") then
            exit(false);

        MenuButtonSibling.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButtonSibling.SetRange("Parent ID", "Parent ID");
        MenuButtonSibling := Rec;
        if MenuButtonSibling.Find(Direction) then begin
            if Direction = '>' then
                Rec := MenuButtonSibling;
            exit(true);
        end;

        exit(false);
    end;

    local procedure SwitchNodes(Source: Record "POS Menu Button"; Target: Record "POS Menu Button")
    var
        SourceHierarchy: Record "POS Menu Button" temporary;
        TargetHierarchy: Record "POS Menu Button" temporary;
    begin
        Source.CopyHierarchy(SourceHierarchy, true);
        Target.CopyHierarchy(TargetHierarchy, true);

        //PAGE.RUNMODAL(50505,SourceHierarchy);
        //PAGE.RUNMODAL(50505,TargetHierarchy);
        //ERROR('');

        SourceHierarchy.FindFirst();
        TargetHierarchy.FindFirst();

        case true of
            // Case 1: same parent
            Source."Parent ID" = Target."Parent ID":
                begin
                    if Source.Ordinal < Target.Ordinal then
                        SwitchNodesSameParent(TargetHierarchy, SourceHierarchy, Source.Ordinal)
                    else
                        SwitchNodesSameParent(SourceHierarchy, TargetHierarchy, Target.Ordinal);
                end;

            // Case 2: Cross-hierarchy move, moving up
            Source.Ordinal > Target.Ordinal:
                MoveSubtreeAboveNode(SourceHierarchy, Target);

            // Case 3: Cross-hierarchy move, moving down:
            else
                MoveSubtreeBelowNode(SourceHierarchy, Target);
        end;
    end;

    local procedure SwitchNodesSameParent(var FirstHierarchy: Record "POS Menu Button" temporary; var SecondHierarchy: Record "POS Menu Button" temporary; NextOrdinal: Integer)
    var
        MenuButton: Record "POS Menu Button";
    begin
        FirstHierarchy.SetCurrentKey(Ordinal);
        if FirstHierarchy.FindSet then
            repeat
                MenuButton := FirstHierarchy;
                MenuButton.Ordinal := NextOrdinal;
                MenuButton.Modify();
                NextOrdinal += 1;
            until FirstHierarchy.Next = 0;

        SecondHierarchy.SetCurrentKey(Ordinal);
        if SecondHierarchy.FindSet then
            repeat
                MenuButton := SecondHierarchy;
                MenuButton.Ordinal := NextOrdinal;
                MenuButton.Modify();
                NextOrdinal += 1;
            until SecondHierarchy.Next = 0;
    end;

    local procedure MoveSubtreeAboveNode(var Hierarchy: Record "POS Menu Button" temporary; Node: Record "POS Menu Button")
    var
        MenuButton: Record "POS Menu Button";
        NextOrdinal: Integer;
        First: Boolean;
    begin
        Hierarchy.SetCurrentKey(Ordinal);
        Hierarchy.FindLast();
        NextOrdinal := Node.Ordinal;

        // Move the node below hierarchy
        MenuButton := Node;
        MenuButton.Ordinal := Hierarchy.Ordinal;
        MenuButton.Modify();

        // Move the hierarchy above node
        First := true;
        if Hierarchy.FindSet then
            repeat
                MenuButton := Hierarchy;
                MenuButton.Ordinal := NextOrdinal;
                if First then
                    MenuButton.CalculateParentID();
                MenuButton.CalculatePath();
                MenuButton.Modify();
                NextOrdinal += 1;
                First := false;
            until Hierarchy.Next = 0;
    end;

    local procedure MoveSubtreeBelowNode(var Hierarchy: Record "POS Menu Button" temporary; Node: Record "POS Menu Button")
    var
        MenuButton: Record "POS Menu Button";
        NextOrdinal: Integer;
        First: Boolean;
    begin
        Hierarchy.SetCurrentKey(Ordinal);
        Hierarchy.FindFirst();
        NextOrdinal := Hierarchy.Ordinal;

        // Move the node above hierarchy
        MenuButton := Node;
        MenuButton.Ordinal := NextOrdinal;
        MenuButton.Modify();
        NextOrdinal += 1;

        // Move the hierarchy below node
        First := true;
        if Hierarchy.FindSet then
            repeat
                MenuButton := Hierarchy;
                MenuButton.Ordinal := NextOrdinal;
                if First then
                    MenuButton."Parent ID" := Node.ID;
                MenuButton.CalculatePath();
                MenuButton.Modify();
                NextOrdinal += 1;
                First := false;
            until Hierarchy.Next = 0;
    end;

    local procedure HandleDescendantsOnDelete()
    var
        MenuButton: Record "POS Menu Button";
        Choice: Option Cancel,Unindent,Delete;
    begin
        //-NPR5.39 [255773]
        //MenuButton.SETRANGE("Parent ID",ID);
        MenuButton.FilterSubtree(Rec, false);
        //+NPR5.39 [255773]
        if MenuButton.IsEmpty then
            exit;

        //-NPR5.39 [255773]
        if not UnattendedDelete then begin
            //+NPR5.39 [255773]
            Choice := StrMenu(Text002, 1, Text001);
            if Choice = Choice::Cancel then
                Error('');
            //-NPR5.39 [255773]
        end else
            Choice := Choice::Delete;
        //+NPR5.39 [255773]

        case Choice of
            Choice::Unindent:
                UnindentDescendantsOnDelete();
            Choice::Delete:
                DeleteDescendantsOnDelete();
        end;
    end;

    local procedure UnindentDescendantsOnDelete()
    var
        MenuButton: Record "POS Menu Button";
        First: Boolean;
    begin
        First := true;

        MenuButton.FilterSubtree(Rec, false);
        if MenuButton.FindSet(true) then
            repeat
                if First then begin
                    MenuButton."Parent ID" := "Parent ID";
                    First := false;
                end;
                MenuButton.Level -= 1;
                MenuButton.CalculatePath();
                MenuButton.Modify();
            until MenuButton.Next = 0;
    end;

    local procedure DeleteDescendantsOnDelete()
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton.FilterSubtree(Rec, false);
        MenuButton.DeleteAll();
    end;

    local procedure RearrangeOrdinalsAfterDelete()
    var
        MenuButton: Record "POS Menu Button";
        NewOrdinal: Integer;
    begin
        NewOrdinal := 1;

        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        if MenuButton.Next(-1) <> 0 then
            NewOrdinal := MenuButton.Ordinal + 1;

        MenuButton.SetFilter(Ordinal, '>%1', Ordinal);
        if MenuButton.FindSet(false) then
            repeat
                MenuButton.Ordinal := NewOrdinal;
                MenuButton.CalculatePath();
                MenuButton.Modify();
                NewOrdinal += 1;
            until MenuButton.Next() = 0;
    end;

    local procedure CalculateID()
    var
        MenuButton: Record "POS Menu Button";
        NewOrdinal: Integer;
    begin
        if ID <> 0 then
            exit;

        MenuButton.SetCurrentKey("Menu Code", ID);
        MenuButton.SetRange("Menu Code", "Menu Code");
        if MenuButton.FindLast then;
        ID := MenuButton.ID + 1;
    end;

    local procedure CalculateOrdinal()
    var
        MenuButton: Record "POS Menu Button";
    begin
        if Ordinal > 0 then
            exit;

        MenuButton.SetCurrentKey("Menu Code", Ordinal);
        MenuButton.SetRange("Menu Code", "Menu Code");
        if MenuButton.FindLast then;
        Ordinal := MenuButton.Ordinal + 1;
    end;

    procedure CalculatePath()
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton := Rec;
        Path := Format(MenuButton.ID);
        while MenuButton.Get("Menu Code", MenuButton."Parent ID") do begin
            Path := StrSubstNo('%1.%2', MenuButton.ID, Path);
        end;
        Path := StrSubstNo('%1.%2', "Menu Code", Path);
    end;

    local procedure CalculateLevel()
    var
        MenuButton: Record "POS Menu Button";
    begin
        if MenuButton.Get("Menu Code", "Parent ID") then
            Level := MenuButton.Level + 1
        else
            Level := 0;
    end;

    procedure CalculateParentID()
    var
        MenuButton: Record "POS Menu Button";
    begin
        "Parent ID" := 0;
        if Level > 0 then begin
            MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
            MenuButton := Rec;
            MenuButton.Next(-1);

            if MenuButton.Level >= Level then begin
                while MenuButton.Level > Level do
                    MenuButton.Get("Menu Code", MenuButton."Parent ID");
                "Parent ID" := MenuButton."Parent ID";
            end else
                "Parent ID" := MenuButton.ID;
            CalculatePath();
        end;
    end;

    procedure CopyHierarchy(var TempMenuButton: Record "POS Menu Button" temporary; Traverse: Boolean)
    var
        MenuButton: Record "POS Menu Button";
    begin
        MenuButton := Rec;
        MenuButton.FilterSubtree(Rec, true);
        TempMenuButton.DeleteAll();
        if MenuButton.FindSet() then
            repeat
                TempMenuButton := MenuButton;
                TempMenuButton.Insert();
            until (MenuButton.Next() = 0) or (not Traverse);
    end;

    local procedure RemoveSubset(var FromSuperset: Record "POS Menu Button" temporary; var Subset: Record "POS Menu Button" temporary) Removed: Boolean
    begin
        if Subset.FindSet then
            repeat
                FromSuperset := Subset;
                Removed := Removed or FromSuperset.Delete();
            until Subset.Next = 0;
    end;

    local procedure LookupBackgroundColor()
    var
        TempRetailList: Record "Retail List" temporary;
        ColorArray: DotNet npNetArray;
        String: DotNet npNetString;
        Separator: DotNet npNetString;
    begin
        Separator := ',';
        String := 'default,green,red,dark-red,gray,purple,indigo,yellow,orange,white';
        ColorArray := String.Split(Separator.ToCharArray());

        foreach String in ColorArray do begin
            TempRetailList.Number += 1;
            TempRetailList.Choice := String;
            TempRetailList.Insert;
        end;

        if PAGE.RunModal(PAGE::"Retail List", TempRetailList) = ACTION::LookupOK then
            Validate("Background Color", TempRetailList.Choice);
    end;

    procedure LocalizeData()
    var
        FieldTmp: Record "Field" temporary;
        LocalizedCaptions: Page "POS Localized Table Data";
    begin
        //-290485 [290485]
        FieldTmp.TableNo := DATABASE::"POS Menu Button";

        FieldTmp."No." := FieldNo(Caption);
        FieldTmp.Insert();

        FieldTmp."No." := FieldNo(Tooltip);
        FieldTmp.Insert();

        LocalizedCaptions.PrepareLocalizationForRecord(RecordId, FieldTmp);
        LocalizedCaptions.RunModal();
        //+290485 [290485]
    end;

    procedure GetLocalizedCaption(FieldNo: Integer): Text
    var
        Localization: Record "POS Localized Caption";
        RecRef: RecordRef;
    begin
        //-290485 [290485]
        if Localization.GetLocalization(RecordId, FieldNo) then
            exit(Localization.Caption);
        RecRef.GetTable(Rec);
        exit(RecRef.Field(FieldNo).Value);
        //+290485 [290485]
    end;

    procedure SetUnattendedDeleteFlag()
    begin
        //-NPR5.39 [255773]
        UnattendedDelete := true;
        //+NPR5.39 [255773]
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnRetrieveItemMetadata(ItemMetadata: DotNet npNetDictionary_Of_T_U)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnRetrieveCustomerMetadata(CustomerMetadata: DotNet npNetDictionary_Of_T_U)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnRetrievePaymentMetadata(PaymentMetadata: DotNet npNetDictionary_Of_T_U)
    begin
    end;
}

