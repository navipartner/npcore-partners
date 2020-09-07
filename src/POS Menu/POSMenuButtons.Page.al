page 6150702 "NPR POS Menu Buttons"
{
    // NPR5.32.11/TSA/20170614  CASE 280806 Added Refresh Action Code button
    // NPR5.32.11/VB /20170621  CASE 281618 Added "Blocking UI" field and corresponding business logic
    // NPR5.32.11/VB /20170627  CASE 282223 Added "Update Tooltips" action and corresponding business logic.
    // NPR5.36/VB /20170912  CASE 289132 Added fields "Background Image Url" and "Caption Position" to support binding specific images to button backgrounds
    // NPR5.37/VB /20171013  CASE 290485 Providing localization support for button captions (and other data)
    // NPR5.37/TSA /20171025 CASE 292656 Changed Action caption to "Refresh Action Code Parameters", and unfavorable styling when params are out of sync
    // NPR5.39/MHA /20180208 CASE 303968 Parameters enabled for "Action Type"::PaymentType
    // NPR5.40/VB  /20180228 CASE 306347 Replacing BLOB-based parameters with physical-table parameters
    // NPR5.42.01/MMV /20180627  CASE 320622 Filter parameters correctly.
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.
    // NPR5.51/THRO/20190718 CASE 361514 Action "Refresh Action Code Parameters" named RefreshActionCodeParameters (for AL Conversion)
    // NPR5.54/VB  /20200408 CASE 399736 Added "Show Plus/Minus Buttons" field.

    Caption = 'POS Menu Buttons';
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Level,Order';
    SourceTable = "NPR POS Menu Button";
    SourceTableView = SORTING("Menu Code");

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
                }
                field(Tooltip; Tooltip)
                {
                    ApplicationArea = All;
                }
                field("Action Type"; "Action Type")
                {
                    ApplicationArea = All;

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
                }
                field("Data Source Name"; "Data Source Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Show Plus/Minus Buttons"; "Show Plus/Minus Buttons")
                {
                    ApplicationArea = All;
                }
                field("Background Color"; "Background Color")
                {
                    ApplicationArea = All;
                }
                field("Foreground Color"; "Foreground Color")
                {
                    ApplicationArea = All;
                }
                field("Icon Class"; "Icon Class")
                {
                    ApplicationArea = All;
                }
                field("Background Image Url"; "Background Image Url")
                {
                    ApplicationArea = All;
                }
                field("Caption Position"; "Caption Position")
                {
                    ApplicationArea = All;
                }
                field("Custom Class Attribute"; "Custom Class Attribute")
                {
                    ApplicationArea = All;
                }
                field(Bold; Bold)
                {
                    ApplicationArea = All;
                }
                field("Font Size"; "Font Size")
                {
                    ApplicationArea = All;
                }
                field("Position X"; "Position X")
                {
                    ApplicationArea = All;
                }
                field("Position Y"; "Position Y")
                {
                    ApplicationArea = All;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                }
                field("Blocking UI"; "Blocking UI")
                {
                    ApplicationArea = All;
                    Editable = IsBlockingUIEnabled;
                }
                field("Secure Method Code"; "Secure Method Code")
                {
                    ApplicationArea = All;
                }
                field("Register Type"; "Register Type")
                {
                    ApplicationArea = All;
                }
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                }
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Available on Desktop"; "Available on Desktop")
                {
                    ApplicationArea = All;
                }
                field("Available in App"; "Available in App")
                {
                    ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Left';
                    ApplicationArea=All;

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
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Right';
                    ApplicationArea=All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Up';
                    ApplicationArea=All;

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
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+Ctrl+Down';
                    ApplicationArea=All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                var
                    POSParameterValue: Record "NPR POS Parameter Value";
                begin
                    //-NPR5.42.01 [320622]
                    POSParameterValue.SetRange("Table No.", 6150701);
                    POSParameterValue.SetRange(Code, "Menu Code");
                    POSParameterValue.SetRange("Record ID", RecordId);
                    POSParameterValue.SetRange(ID, ID);
                    PAGE.RunModal(PAGE::"NPR POS Parameter Values", POSParameterValue);
                    //+NPR5.42.01 [320622]
                end;
            }
            action("Popup Menu")
            {
                Caption = 'Popup Menu';
                Enabled = IsPopupEnabled;
                Image = Hierarchy;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea=All;

                trigger OnAction()
                begin
                    //-290485 [290485]
                    LocalizeData();
                    //+290485 [290485]
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

        //-NPR5.40 [306347]
        ////-NPR5.37 [292656]
        //NeedParameterRefresh := Rec.NeedRefreshActionCode ();
        ////+NPR5.37 [292656]
        //+NPR5.40 [306347]
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
        //-NPR5.40 [306347]
        POSAction.DiscoverActions();
        //+NPR5.40 [306347]
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
        //-NPR5.32.11 [282223]
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
        //+NPR5.32.11 [282223]
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

        //-NPR5.40 [306347]
        NeedParameterRefresh := Rec.RefreshParametersRequired();
        //+NPR5.40 [306347]
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
        //-NPR5.39 [303968]
        //IsParametersEnabled := "Action Type" IN ["Action Type"::Action,"Action Type"::Item,"Action Type"::PopupMenu];
        IsParametersEnabled := "Action Type" in ["Action Type"::Action, "Action Type"::Item, "Action Type"::PopupMenu, "Action Type"::PaymentType];
        //+NPR5.39 [303968]
        IsPopupEnabled := "Action Type" = "Action Type"::PopupMenu;
        //-NPR5.32.11 [281618]
        IsBlockingUIEnabled := "Action Type" <> "Action Type"::Action;
        //+NPR5.32.11 [281618]
    end;

    local procedure DoRefreshActionCode()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin

        //-NPR5.37 [292656]
        CurrPage.SetSelectionFilter(POSMenuButton);
        if (POSMenuButton.FindSet()) then begin
            repeat
                //-NPR5.40 [306347]
                //POSMenuButton.RefreshActionCode ();
                POSMenuButton.RefreshParameters();
            //+NPR5.40 [306347]
            until (POSMenuButton.Next() = 0);
        end;
        //+NPR5.37 [292656]
    end;
}

