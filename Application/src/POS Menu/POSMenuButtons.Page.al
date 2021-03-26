page 6150702 "NPR POS Menu Buttons"
{
    Caption = 'POS Menu Buttons';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Reports,Level,Order';
    SourceTable = "NPR POS Menu Button";
    SourceTableView = SORTING("Menu Code", Ordinal);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Level;
                IndentationControls = Caption;
                field(Caption; Caption)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Caption field';
                }
                field(Tooltip; Tooltip)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tooltip field';
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Action Type field';

                    trigger OnValidate()
                    begin
                        SetActionCodeEditable();
                    end;
                }
                field("Action Code"; "Action Code")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = NeedParameterRefresh;
                    ToolTip = 'Specifies the value of the Action Code field';
                }
                field("Data Source Name"; "Data Source Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Source Name field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Show Plus/Minus Buttons"; "Show Plus/Minus Buttons")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Show Plus/Minus Buttons field';
                }
                field("Background Color"; "Background Color")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Background Color field';
                }
                field("Foreground Color"; "Foreground Color")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Foreground Color field';
                }
                field("Icon Class"; "Icon Class")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Icon Class field';
                }
                field("Background Image Url"; "Background Image Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Background Image Url field';
                }
                field("Caption Position"; "Caption Position")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Caption Position field';
                }
                field("Custom Class Attribute"; "Custom Class Attribute")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Class Attribute field';
                }
                field(Bold; Bold)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bold field';
                }
                field("Font Size"; "Font Size")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Font Size field';
                }
                field("Position X"; "Position X")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position X field';
                }
                field("Position Y"; "Position Y")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Position Y field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
                field("Blocking UI"; "Blocking UI")
                {
                    ApplicationArea = All;
                    Editable = IsBlockingUIEnabled;
                    ToolTip = 'Specifies the value of the Blocking UI field';
                }
                field("Secure Method Code"; "Secure Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Secure Method Code field';
                }
                field("Register Type"; "Register Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View Profile field';
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RefreshActionCodeParameters)
            {
                Caption = 'Refresh Action Code Parameters';
                Enabled = IsParametersEnabled;
                Image = RefreshText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Refresh Action Code Parameters action';

                trigger OnAction()
                begin
                    DoRefreshActionCode();
                end;
            }
            action("Update Tooltips")
            {
                Caption = 'Update Tooltips';
                Image = UpdateDescription;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Update Tooltips action';

                trigger OnAction()
                begin
                    Action_UpdateTooltips();
                end;
            }
            group(Level)
            {
                Caption = 'Level';
                action(Unindent)
                {
                    Caption = 'Unindent';
                    Enabled = UnindentEnabled;
                    Image = PreviousRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Left';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Unindent action';

                    trigger OnAction()
                    begin
                        Action_Unindent();
                    end;
                }
                action(Indent)
                {
                    Caption = 'Indent';
                    Enabled = IndentEnabled;
                    Image = NextRecord;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Right';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Indent action';

                    trigger OnAction()
                    begin
                        Action_Indent();
                    end;
                }
            }
            group(Order)
            {
                Caption = 'Order';
                action("Move Up")
                {
                    Caption = 'Move Up';
                    Enabled = MoveUpEnabled;
                    Image = MoveUp;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Up';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Move Up action';

                    trigger OnAction()
                    begin
                        Action_MoveUp();
                    end;
                }
                action("Move Down")
                {
                    Caption = 'Move Down';
                    Enabled = MoveDownEnabled;
                    Image = MoveDown;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Down';
                    ApplicationArea = All;
                    ToolTip = 'Executes the Move Down action';

                    trigger OnAction()
                    begin
                        Action_MoveDown();
                    end;
                }
            }
        }
        area(navigation)
        {
            action(Parameters)
            {
                Caption = 'Parameters';
                Enabled = IsParametersEnabled;
                Image = Answers;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Parameters action';

                trigger OnAction()
                var
                    POSParameterValue: Record "NPR POS Parameter Value";
                begin
                    POSParameterValue.SetRange("Table No.", 6150701);
                    POSParameterValue.SetRange(Code, "Menu Code");
                    POSParameterValue.SetRange("Record ID", RecordId);
                    POSParameterValue.SetRange(ID, ID);
                    PAGE.RunModal(PAGE::"NPR POS Parameter Values", POSParameterValue);
                end;
            }
            action("Popup Menu")
            {
                Caption = 'Popup Menu';
                Enabled = IsPopupEnabled;
                Image = Hierarchy;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Popup Menu action';

                trigger OnAction()
                begin
                    ShowPopup();
                end;
            }
            action("Caption Localization")
            {
                Caption = 'Caption Localization';
                Image = Language;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Caption Localization action';

                trigger OnAction()
                begin
                    LocalizeData();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetActionEnabledAttributes();
        GetRowStyle();
    end;

    trigger OnAfterGetRecord()
    begin
        SetActionEnabledAttributes();
        GetRowStyle();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if not BelowxRec then
            Rec.InsertRow();
    end;

    trigger OnOpenPage()
    var
        POSAction: Record "NPR POS Action";
    begin
        SetColumnVisibleAttributes();
        CurrPage.Caption := StrSubstNo(Text001, "Menu Code");
        POSAction.DiscoverActions();
    end;

    var
        Text001: Label 'Menu Buttons Setup: %1';
        MenuCodeVisible: Boolean;
        UnindentEnabled: Boolean;
        IndentEnabled: Boolean;
        MoveUpEnabled: Boolean;
        MoveDownEnabled: Boolean;
        HasSubMenus: Boolean;
        ActionTypeEnabled: Boolean;
        ActionCodeEnabled: Boolean;
        IsParametersEnabled: Boolean;
        IsPopupEnabled: Boolean;
        IsBlockingUIEnabled: Boolean;
        RowStyle: Text;
        NeedParameterRefresh: Boolean;

    local procedure Action_Unindent()
    begin
        Rec.UnIndent();
        CurrPage.Update(false);
    end;

    local procedure Action_Indent()
    begin
        Rec.Indent();
        CurrPage.Update(false);
    end;

    local procedure Action_MoveUp()
    begin
        Rec.MoveUp();
        CurrPage.Update(false);
    end;

    local procedure Action_MoveDown()
    begin
        Rec.MoveDown();
        CurrPage.Update(false);
    end;

    local procedure Action_UpdateTooltips()
    var
        POSAction: Record "NPR POS Action";
        MenuButton: Record "NPR POS Menu Button";
        Modified: Boolean;
    begin
        MenuButton.Copy(Rec);
        MenuButton.SetRange("Action Type", MenuButton."Action Type"::Action);
        MenuButton.SetRange(Tooltip, '');
        if MenuButton.FindSet(true) then
            repeat
                if POSAction.Get(MenuButton."Action Code") then begin
                    MenuButton.Tooltip := POSAction.Tooltip;
                    MenuButton.Modify(false);
                    Modified := true;
                end;
            until MenuButton.Next = 0;

        if Modified then
            CurrPage.Update(false);
    end;

    local procedure ShowPopup()
    var
        PopupMenuButton: Record "NPR POS Menu Button";
    begin
        TestField("Action Type", "Action Type"::PopupMenu);
        PopupMenuButton.SetRange("Menu Code", "Action Code");
        PAGE.Run(0, PopupMenuButton);
    end;

    local procedure GetRowStyle()
    begin
        RowStyle := '';
        if HasSubMenus then
            RowStyle := 'Strong';

        NeedParameterRefresh := Rec.RefreshParametersRequired();
    end;

    local procedure SetColumnVisibleAttributes()
    begin
        MenuCodeVisible := (GetRangeMin("Menu Code") = GetRangeMax("Menu Code")) and (GetRangeMax("Menu Code") = '');
    end;

    local procedure SetActionEnabledAttributes()
    var
        MenuButton: Record "NPR POS Menu Button";
    begin
        MoveUpEnabled := Rec.MoveUpAllowed();
        MoveDownEnabled := Rec.MoveDownAllowed();
        UnindentEnabled := Rec.UnIndentAllowed();
        IndentEnabled := Rec.IndentAllowed();
        ActionTypeEnabled := Rec.ActionIsEditable();

        MenuButton.SetRange("Menu Code", "Menu Code");
        MenuButton.SetRange("Parent ID", ID);
        HasSubMenus := not MenuButton.IsEmpty();

        IsParametersEnabled := "Action Type" = "Action Type"::Action;

        SetActionCodeEditable();
    end;

    local procedure SetActionCodeEditable()
    begin
        ActionCodeEnabled := ActionTypeEnabled and ("Action Type" <> "Action Type"::Submenu);
        IsParametersEnabled := "Action Type" in ["Action Type"::Action, "Action Type"::Item, "Action Type"::PopupMenu, "Action Type"::PaymentType];
        IsPopupEnabled := "Action Type" = "Action Type"::PopupMenu;
        IsBlockingUIEnabled := "Action Type" <> "Action Type"::Action;
    end;

    local procedure DoRefreshActionCode()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        CurrPage.SetSelectionFilter(POSMenuButton);
        if (POSMenuButton.FindSet()) then begin
            repeat
                POSMenuButton.RefreshParameters();
            until (POSMenuButton.Next() = 0);
        end;
    end;
}

