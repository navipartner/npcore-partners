page 6150702 "NPR POS Menu Buttons"
{
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

                    ToolTip = 'Specifies the value of the Caption field';
                    ApplicationArea = NPRRetail;
                }
                field(Tooltip; Rec.Tooltip)
                {

                    ToolTip = 'Specifies the value of the Tooltip field';
                    ApplicationArea = NPRRetail;
                }
                field("Action Type"; Rec."Action Type")
                {

                    ToolTip = 'Specifies the value of the Action Type field';
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
                    ToolTip = 'Specifies the value of the Action Code field';
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

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Show Plus/Minus Buttons"; Rec."Show Plus/Minus Buttons")
                {

                    ToolTip = 'Specifies the value of the Show Plus/Minus Buttons field';
                    ApplicationArea = NPRRetail;
                }
                field("Background Color"; Rec."Background Color")
                {

                    ToolTip = 'Specifies the value of the Background Color field';
                    ApplicationArea = NPRRetail;
                }
                field("Foreground Color"; Rec."Foreground Color")
                {

                    ToolTip = 'Specifies the value of the Foreground Color field';
                    ApplicationArea = NPRRetail;
                }
                field("Icon Class"; Rec."Icon Class")
                {

                    ToolTip = 'Specifies the value of the Icon Class field';
                    ApplicationArea = NPRRetail;
                }
                field("Background Image Url"; Rec."Background Image Url")
                {

                    ToolTip = 'Specifies the value of the Background Image Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Caption Position"; Rec."Caption Position")
                {

                    ToolTip = 'Specifies the value of the Caption Position field';
                    ApplicationArea = NPRRetail;
                }
                field("Custom Class Attribute"; Rec."Custom Class Attribute")
                {

                    ToolTip = 'Specifies the value of the Custom Class Attribute field';
                    ApplicationArea = NPRRetail;
                }
                field(Bold; Rec.Bold)
                {

                    ToolTip = 'Specifies the value of the Bold field';
                    ApplicationArea = NPRRetail;
                }
                field("Font Size"; Rec."Font Size")
                {

                    ToolTip = 'Specifies the value of the Font Size field';
                    ApplicationArea = NPRRetail;
                }
                field("Position X"; Rec."Position X")
                {

                    ToolTip = 'Specifies the value of the Position X field';
                    ApplicationArea = NPRRetail;
                }
                field("Position Y"; Rec."Position Y")
                {

                    ToolTip = 'Specifies the value of the Position Y field';
                    ApplicationArea = NPRRetail;
                }
                field(Enabled; Rec.Enabled)
                {

                    ToolTip = 'Specifies the value of the Enabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Secure Method Code"; Rec."Secure Method Code")
                {

                    ToolTip = 'Specifies the value of the Secure Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Register Type"; Rec."Register Type")
                {

                    ToolTip = 'Specifies the value of the POS View Profile field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
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

                ToolTip = 'Executes the Refresh Action Code Parameters action';
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

                ToolTip = 'Executes the Update Tooltips action';
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

                    ToolTip = 'Executes the Unindent action';
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

                    ToolTip = 'Executes the Indent action';
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

                    ToolTip = 'Executes the Move Up action';
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

                    ToolTip = 'Executes the Move Down action';
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

                ToolTip = 'Executes the Parameters action';
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

                ToolTip = 'Executes the Popup Menu action';
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

                ToolTip = 'Executes the Caption Localization action';
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
