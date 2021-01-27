table 6150701 "NPR POS Menu Button"
{
    Caption = 'POS Menu Button';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Menu Buttons";
    LookupPageID = "NPR POS Menu Buttons";

    fields
    {
        field(1; "Menu Code"; Code[20])
        {
            Caption = 'Menu Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Menu";
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
                CalculateLevel;
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
        field(13; "Action Type"; Enum "NPR Action Type")
        {
            Caption = 'Action Type';
            DataClassification = CustomerContent;

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
            TableRelation = IF ("Action Type" = CONST(PopupMenu)) "NPR POS Menu"
            ELSE
            IF ("Action Type" = CONST(Item)) Item
            ELSE
            IF ("Action Type" = CONST(Action)) "NPR POS Action" WHERE(Type = FILTER(Generic | Button),
                                                                                      Blocked = CONST(false))
            ELSE
            IF ("Action Type" = CONST(Customer)) Customer
            ELSE
            IF ("Action Type" = CONST(PaymentType)) "NPR Payment Type POS";

            trigger OnLookup()
            begin
                LookupActionCode();
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
                TempDataSource: Record "NPR POS Data Source Discovery";
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
        field(26; "Font Size"; Enum "NPR Button Font Size")
        {
            Caption = 'Font Size';
            DataClassification = CustomerContent;
            InitValue = Normal;
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
        field(29; Enabled; Enum "NPR Button Enabled State")
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

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
            TableRelation = "NPR POS Secure Method";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                SecureMethodTmp: Record "NPR POS Secure Method" temporary;
            begin
                if ("Secure Method Code" = '') then
                    exit;

                SecureMethodTmp.RunDiscovery();
                SecureMethodTmp.Get("Secure Method Code");
            end;
        }
        field(34; "Show Plus/Minus Buttons"; Boolean)
        {
            Caption = 'Show Plus/Minus Buttons';
            DataClassification = CustomerContent;
            Description = 'NPR5.54';

            trigger OnValidate()
            begin
                if "Show Plus/Minus Buttons" then
                    TestField("Action Type", "Action Type"::Item);
            end;
        }
        field(41; "Register Type"; Code[20])
        {
            Caption = 'POS View Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS View Profile";
        }
        field(42; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Register";
        }
        field(43; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            TableRelation = "Salesperson/Purchaser".Code;
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
        UnattendedDelete := false;
        ClearParameters();
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
        POSActionMgt: Codeunit "NPR POS Action Management";
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
        PaymentType: Record "NPR Payment Type POS";
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
        POSAction: Record "NPR POS Action";
    begin
        if ("Action Type" = "Action Type"::Action) then begin
            if POSAction.Get("Action Code") then begin
                if POSAction."Bound to DataSource" then
                    Enabled := Enabled::Auto;
                "Data Source Name" := POSAction."Data Source Name";
                "Blocking UI" := POSAction."Blocking UI";
                if (POSAction.Tooltip <> '') and (Tooltip = '') then
                    Tooltip := POSAction.Tooltip;
                if (POSAction."Secure Method Code" <> '') and ("Secure Method Code" = '') then
                    "Secure Method Code" := POSAction."Secure Method Code";
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
        Clear("Blocking UI");
        Clear(Tooltip);
        ClearParameters();
    end;

    local procedure ClearParameters()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        ParamMgt.ClearParametersForRecord(RecordId, 0);
    end;

    local procedure CopyParameters()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if "Action Code" = xRec."Action Code" then
            exit;

        ClearParameters();
        case "Action Type" of
            "Action Type"::Action:
                ParamMgt.CopyFromActionToMenuButton("Action Code", Rec);
            "Action Type"::PopupMenu:
                SetupPopupSizeParameters();
        end;
    end;

    local procedure LookupActionCode()
    var
        Customer: Record Customer;
        Item: Record Item;
        PaymentType: Record "NPR Payment Type POS";
        POSMenu: Record "NPR POS Menu";
        CustomerList: Page "Customer List";
        ItemList: Page "Item List";
        PaymentTypes: Page "NPR Payment Type - Register";
        POSMenus: Page "NPR POS Menus";
    begin
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
    end;

    local procedure SetupPopupSizeParameters()
    var
        ParamValue: Record "NPR POS Parameter Value";
    begin
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
    end;

    procedure RefreshParameters()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
        ParColumns: Record "NPR POS Parameter Value";
        ParRows: Record "NPR POS Parameter Value";
        ParamValue: Record "NPR POS Parameter Value";
        ParColumnsKnown: Boolean;
        ParRowsKnown: Boolean;
    begin
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
    end;

    procedure RefreshParametersRequired(): Boolean
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if ("Action Type" <> "Action Type"::Action) then
            exit(false)
        else
            exit(ParamMgt.RefreshParametersRequired(RecordId, "Menu Code", ID, "Action Code"));
    end;

    procedure GetAction(var ActionOut: Interface "NPR IAction"; POSSession: Codeunit "NPR POS Session"; Source: Text; var POSParameterValue: Record "NPR POS Parameter Value"): Boolean
    var
        ActionMgt: Codeunit "NPR POS Action Management";
        ErrorText: Text;
        POSAction: Record "NPR POS Action";
        ActionInterface: interface "NPR IAction";
    begin
        if ("Action Type" = "Action Type"::SubMenu) or (not "Action Type".Ordinals().Contains("Action Type".AsInteger())) then
            exit(false);

        ActionInterface := "Action Type";
        ActionInterface.ConfigureFromMenuButton(Rec, POSSession, ActionOut);

        StoreButtonParameters(ActionOut, POSParameterValue);
        StoreDataSource(ActionOut);
        StoreActionOtherConfiguration(ActionOut, POSSession);
        ActionMgt.IsValidActionConfiguration(POSSession, ActionOut, Source, ErrorText, true);

        exit(true);
    end;

    local procedure HandleEnabled()
    var
        POSAction: Record "NPR POS Action";
    begin
        if Enabled = Enabled::Auto then begin
            TestField("Action Type", "Action Type"::Action);
            POSAction.Get("Action Code");
            POSAction.TestField("Bound to DataSource");
        end;
    end;

    local procedure StoreButtonParameters(ActionIn: interface "NPR IAction"; var POSParameterValue: Record "NPR POS Parameter Value" temporary)
    begin
        if not POSParameterValue.GetParamFilterIndicator() then begin
            POSParameterValue.SetRange("Table No.", DATABASE::"NPR POS Menu Button");
            POSParameterValue.SetRange(Code, "Menu Code");
            POSParameterValue.SetRange("Record ID", RecordId);
            POSParameterValue.SetRange(ID, ID);
        end;

        if POSParameterValue.FindSet then
            repeat
                POSParameterValue.AddParameterToAction(ActionIn);
            until POSParameterValue.Next = 0;
    end;

    local procedure StoreActionOtherConfiguration(ActionIn: Interface "NPR IAction"; POSSession: Codeunit "NPR POS Session")
    var
        TempParam: Record "NPR POS Parameter Value" temporary;
        POSAction: Record "NPR POS Action";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if "Blocking UI" then
            ActionIn.Content.Add('Blocking', true);

        if (not POSSession.RetrieveSessionAction("Action Code", POSAction)) then
            exit;

        ActionIn.Content.Add('requirePosUnitType', Format(POSAction."Requires POS Type", 0, 9));
    end;

    local procedure StoreDataSource(ActionIn: Interface "NPR IAction")
    begin
        if "Data Source Name" <> '' then
            ActionIn.Content.Add('dataSource', "Data Source Name");
    end;

    procedure StoreButtonConfiguration(MenuButtonObj: Codeunit "NPR POS Menu Button")
    begin
        if Tooltip <> '' then
            MenuButtonObj.SetTooltip(GetLocalizedCaption(FieldNo(Tooltip)));
        if "Background Image Url" <> '' then begin
            MenuButtonObj.Content.Add('BackgroundImageUrl', "Background Image Url");
            MenuButtonObj.Content.Add('CaptionPosition', "Caption Position");
        end;
        if "Secure Method Code" <> '' then
            MenuButtonObj.Content.Add('SecureMethod', "Secure Method Code");
    end;

    procedure SetSortOrderAndBaseMenuFilter(MenuCode: Code[20])
    begin
        Rec.Reset();
        Rec.SetCurrentKey("Menu Code", Ordinal);
        Rec.SetRange("Menu Code", MenuCode);
    end;

    procedure FilterSubtree(MenuButton: Record "NPR POS Menu Button"; IncludingThis: Boolean)
    var
        This: Text;
    begin
        if IncludingThis then
            This := MenuButton.Path + '|';
        Rec.SetFilter(Path, StrSubstNo('%2%1.*', MenuButton.Path, This));
    end;

    procedure IndentAllowed(): Boolean
    var
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
    begin
        exit(Level > 0);
    end;

    procedure MoveUpAllowed(): Boolean
    var
        MenuButton: Record "NPR POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        exit(MenuButton.FindTarget('<'));
    end;

    procedure MoveDownAllowed(): Boolean
    var
        MenuButton: Record "NPR POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;
        exit(MenuButton.FindTarget('>'));
    end;

    procedure ActionIsEditable(): Boolean
    var
        MenuButton: Record "NPR POS Menu Button";
    begin
        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton.SetRange("Parent ID", ID);
        exit(MenuButton.IsEmpty);
    end;

    procedure InsertRow()
    var
        MenuButton: Record "NPR POS Menu Button";
        TempMenuButton: Record "NPR POS Menu Button" temporary;
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
        MenuButton: Record "NPR POS Menu Button";
        MenuButton2: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
        MenuButton2: Record "NPR POS Menu Button";
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
        CopyRec: Record "NPR POS Menu Button";
        MenuButton: Record "NPR POS Menu Button";
        TempMoveUp: Record "NPR POS Menu Button" temporary;
        TempMoveDown: Record "NPR POS Menu Button" temporary;
    begin
        if not MoveUpAllowed() then
            exit;

        CopyRec := Rec;

        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;

        if not MenuButton.FindTarget('<') then
            exit;

        SwitchNodes(Rec, MenuButton);
        MenuButton := CopyRec;
        MenuButton.Reset();
        MenuButton.Find();
        Rec := MenuButton;
    end;

    procedure MoveDown()
    var
        CopyRec: Record "NPR POS Menu Button";
        MenuButton: Record "NPR POS Menu Button";
        TempMoveUp: Record "NPR POS Menu Button" temporary;
        TempMoveDown: Record "NPR POS Menu Button" temporary;
    begin
        if not MoveDownAllowed() then
            exit;

        CopyRec := Rec;

        MenuButton.SetSortOrderAndBaseMenuFilter("Menu Code");
        MenuButton := Rec;

        if not MenuButton.FindTarget('>') then
            exit;
        SwitchNodes(Rec, MenuButton);

        MenuButton := CopyRec;
        MenuButton.Reset();
        MenuButton.Find();
        Rec := MenuButton;
    end;

    procedure FindTarget(Direction: Code[10]): Boolean
    var
        MenuButton: Record "NPR POS Menu Button";
        MenuButtonSibling: Record "NPR POS Menu Button";
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

    local procedure SwitchNodes(Source: Record "NPR POS Menu Button"; Target: Record "NPR POS Menu Button")
    var
        SourceHierarchy: Record "NPR POS Menu Button" temporary;
        TargetHierarchy: Record "NPR POS Menu Button" temporary;
    begin
        Source.CopyHierarchy(SourceHierarchy, true);
        Target.CopyHierarchy(TargetHierarchy, true);

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

    local procedure SwitchNodesSameParent(var FirstHierarchy: Record "NPR POS Menu Button" temporary; var SecondHierarchy: Record "NPR POS Menu Button" temporary; NextOrdinal: Integer)
    var
        MenuButton: Record "NPR POS Menu Button";
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

    local procedure MoveSubtreeAboveNode(var Hierarchy: Record "NPR POS Menu Button" temporary; Node: Record "NPR POS Menu Button")
    var
        MenuButton: Record "NPR POS Menu Button";
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

    local procedure MoveSubtreeBelowNode(var Hierarchy: Record "NPR POS Menu Button" temporary; Node: Record "NPR POS Menu Button")
    var
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
        Choice: Option Cancel,Unindent,Delete;
    begin
        MenuButton.FilterSubtree(Rec, false);
        if MenuButton.IsEmpty then
            exit;

        if not UnattendedDelete then begin
            Choice := StrMenu(Text002, 1, Text001);
            if Choice = Choice::Cancel then
                Error('');
        end else
            Choice := Choice::Delete;

        case Choice of
            Choice::Unindent:
                UnindentDescendantsOnDelete();
            Choice::Delete:
                DeleteDescendantsOnDelete();
        end;
    end;

    local procedure UnindentDescendantsOnDelete()
    var
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
    begin
        MenuButton.FilterSubtree(Rec, false);
        MenuButton.DeleteAll();
    end;

    local procedure RearrangeOrdinalsAfterDelete()
    var
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
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
        MenuButton: Record "NPR POS Menu Button";
    begin
        if MenuButton.Get("Menu Code", "Parent ID") then
            Level := MenuButton.Level + 1
        else
            Level := 0;
    end;

    procedure CalculateParentID()
    var
        MenuButton: Record "NPR POS Menu Button";
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

    procedure CopyHierarchy(var TempMenuButton: Record "NPR POS Menu Button" temporary; Traverse: Boolean)
    var
        MenuButton: Record "NPR POS Menu Button";
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

    local procedure RemoveSubset(var FromSuperset: Record "NPR POS Menu Button" temporary; var Subset: Record "NPR POS Menu Button" temporary) Removed: Boolean
    begin
        if Subset.FindSet then
            repeat
                FromSuperset := Subset;
                Removed := Removed or FromSuperset.Delete();
            until Subset.Next = 0;
    end;

    local procedure LookupBackgroundColor()
    var
        TempRetailList: Record "NPR Retail List" temporary;
        String: Text;
        Separator: Text;
        ColorList: List of [Text];
    begin
        Separator := ',';
        String := 'default,green,red,dark-red,gray,purple,indigo,yellow,orange,white';
        ColorList := String.Split(Separator);

        foreach String in ColorList do begin
            TempRetailList.Number += 1;
            TempRetailList.Choice := String;
            TempRetailList.Insert;
        end;

        if PAGE.RunModal(PAGE::"NPR Retail List", TempRetailList) = ACTION::LookupOK then
            Validate("Background Color", TempRetailList.Choice);
    end;

    procedure LocalizeData()
    var
        FieldTmp: Record "Field" temporary;
        LocalizedCaptions: Page "NPR POS Localized Table Data";
    begin
        FieldTmp.TableNo := DATABASE::"NPR POS Menu Button";

        FieldTmp."No." := FieldNo(Caption);
        FieldTmp.Insert();

        FieldTmp."No." := FieldNo(Tooltip);
        FieldTmp.Insert();

        LocalizedCaptions.PrepareLocalizationForRecord(RecordId, FieldTmp);
        LocalizedCaptions.RunModal();
    end;

    procedure GetLocalizedCaption(FieldNo: Integer): Text
    var
        Localization: Record "NPR POS Localized Caption";
        RecRef: RecordRef;
    begin
        if Localization.GetLocalization(RecordId, FieldNo) then
            exit(Localization.Caption);
        RecRef.GetTable(Rec);
        exit(RecRef.Field(FieldNo).Value);
    end;

    procedure SetUnattendedDeleteFlag()
    begin
        UnattendedDelete := true;
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnRetrieveItemMetadata(ItemMetadata: JsonObject)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnRetrieveCustomerMetadata(CustomerMetadata: JsonObject)
    begin
    end;

    [IntegrationEvent(TRUE, false)]
    procedure OnRetrievePaymentMetadata(PaymentMetadata: JsonObject)
    begin
    end;
}
