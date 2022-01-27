page 6150702 "NPR POS Menu Buttons"
{
    Extensible = False;
    Caption = 'POS Menu Buttons';
    PageType = List;
    UsageCategory = Administration;

    PromotedActionCategories = 'New,Process,Reports,Level,Order';
    SourceTable = "NPR POS Menu Button";
    SourceTableView = SORTING("Menu Code", Ordinal);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                IndentationColumn = Rec.Level;
                IndentationControls = Caption;
                field(Caption; Rec.Caption)
                {

                    ToolTip = 'Specifies the caption which will be displayed on the button';
                    ApplicationArea = NPRRetail;
                }
                field(Tooltip; Rec.Tooltip)
                {

                    ToolTip = 'Specifies what will be displayed when the cursor hovers over the button';
                    ApplicationArea = NPRRetail;
                }
                field("Action Type"; Rec."Action Type")
                {

                    ToolTip = 'Specifies what type of action is triggered by clicking the button';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        SetActionCodeEditable();
                    end;
                }
                field("Action Code"; Rec."Action Code")
                {

                    Style = Unfavorable;
                    StyleExpr = NeedParameterRefresh;
                    ToolTip = 'Specifies what workflow is defined for the action';
                    ApplicationArea = NPRRetail;
                }
                field("Data Source Name"; Rec."Data Source Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Source Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies whether the action is blocked or not';
                    ApplicationArea = NPRRetail;
                }
                field("Show Plus/Minus Buttons"; Rec."Show Plus/Minus Buttons")
                {

                    ToolTip = 'Specifies whether or not plus/minus buttons will be displayed';
                    ApplicationArea = NPRRetail;
                }
                field("Background Color"; Rec."Background Color")
                {

                    ToolTip = 'Specifies the background color that is displayed on the button';
                    ApplicationArea = NPRRetail;
                }
                field("Foreground Color"; Rec."Foreground Color")
                {

                    ToolTip = 'Specifies the foreground color that is displayed on the button';
                    ApplicationArea = NPRRetail;
                }
                field("Icon Class"; Rec."Icon Class")
                {

                    ToolTip = 'Specifies the logo that is used on the button';
                    ApplicationArea = NPRRetail;
                }
                field("Background Image Url"; Rec."Background Image Url")
                {

                    ToolTip = 'Specifies the url for the background image';
                    ApplicationArea = NPRRetail;
                }
                field("Caption Position"; Rec."Caption Position")
                {

                    ToolTip = 'Specifies where on the button the caption should be';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Class Attribute"; Rec."Custom Class Attribute")
                {

                    ToolTip = 'Specifies what the custom class attribute is';
                    ApplicationArea = NPRRetail;
                }
                field("Position X"; Rec."Position X")
                {

                    ToolTip = 'Specifies the position of the button on the x-axis';
                    ApplicationArea = NPRRetail;
                }
                field("Position Y"; Rec."Position Y")
                {

                    ToolTip = 'Specifies the position of the button on the y-axis';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies whether or not the button is enabled or not';
                    ApplicationArea = NPRRetail;
                }
                field("Secure Method Code"; Rec."Secure Method Code")
                {

                    ToolTip = 'Specifies if the button has been assigned a secure method code';
                    ApplicationArea = NPRRetail;
                }
                field("Register Type"; Rec."Register Type")
                {

                    ToolTip = 'Specifies if the button has been allocated to a POS view profile';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies if the button has been allocated to a POS Unit';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies if the button has been allocated to a salesperson';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Refreshes the Action Code Parameters';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Updates the tooltips';
                ApplicationArea = NPRRetail;

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

                    ToolTip = 'Unindents the selected button';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Indents the selected button';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Moves the selected button up';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Moves the selected button down';
                    ApplicationArea = NPRRetail;

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

                ToolTip = 'View/edit the parameters';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    POSParameterValue: Record "NPR POS Parameter Value";
                begin
                    POSParameterValue.SetRange("Table No.", 6150701);
                    POSParameterValue.SetRange(Code, Rec."Menu Code");
                    POSParameterValue.SetRange("Record ID", Rec.RecordId);
                    POSParameterValue.SetRange(ID, Rec.ID);
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

                ToolTip = 'View/edit the connected popup menu';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'View/edit the caption localizations';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.LocalizeData();
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
        CurrPage.Caption := StrSubstNo(Text001, Rec."Menu Code");
        POSAction.DiscoverActions();
    end;

    var
        Text001: Label 'Menu Buttons Setup: %1';
        UnindentEnabled: Boolean;
        IndentEnabled: Boolean;
        MoveUpEnabled: Boolean;
        MoveDownEnabled: Boolean;
        HasSubMenus: Boolean;
        IsParametersEnabled: Boolean;
        IsPopupEnabled: Boolean;
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
            until MenuButton.Next() = 0;

        if Modified then
            CurrPage.Update(false);
    end;

    local procedure ShowPopup()
    var
        PopupMenuButton: Record "NPR POS Menu Button";
    begin
        Rec.TestField("Action Type", Rec."Action Type"::PopupMenu);
        PopupMenuButton.SetRange("Menu Code", Rec."Action Code");
        PAGE.Run(0, PopupMenuButton);
    end;

    local procedure GetRowStyle()
    begin
        RowStyle := '';
        if HasSubMenus then
            RowStyle := 'Strong';

        NeedParameterRefresh := Rec.RefreshParametersRequired();
    end;

    local procedure SetActionEnabledAttributes()
    var
        MenuButton: Record "NPR POS Menu Button";
    begin
        MoveUpEnabled := Rec.MoveUpAllowed();
        MoveDownEnabled := Rec.MoveDownAllowed();
        UnindentEnabled := Rec.UnIndentAllowed();
        IndentEnabled := Rec.IndentAllowed();

        MenuButton.SetRange("Menu Code", Rec."Menu Code");
        MenuButton.SetRange("Parent ID", Rec.ID);
        HasSubMenus := not MenuButton.IsEmpty();

        IsParametersEnabled := Rec."Action Type" = Rec."Action Type"::Action;

        SetActionCodeEditable();
    end;

    local procedure SetActionCodeEditable()
    begin
        IsParametersEnabled := Rec."Action Type" in [Rec."Action Type"::Action, Rec."Action Type"::Item, Rec."Action Type"::PopupMenu, Rec."Action Type"::PaymentType];
        IsPopupEnabled := Rec."Action Type" = Rec."Action Type"::PopupMenu;
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
