page 6150707 "NPR POS Setup"
{
    Caption = 'POS Setup';
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "NPR POS Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
            group("Actions")
            {
                field("Login Action Code"; "Login Action Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = LoginActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Login Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Login Action Code", FieldNo("Login Action Code"));
                    end;
                }
                field("Text Enter Action Code"; "Text Enter Action Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = TextEnterActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Text Enter Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Text Enter Action Code", FieldNo("Text Enter Action Code"));
                    end;
                }
                field("Item Insert Action Code"; "Item Insert Action Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = ItemInsertActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Item Insert Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Item Insert Action Code", FieldNo("Item Insert Action Code"));
                    end;
                }
                field("Payment Action Code"; "Payment Action Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = PaymentActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Payment Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Payment Action Code", FieldNo("Payment Action Code"));
                    end;
                }
                field("Customer Action Code"; "Customer Action Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = CustomerActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Customer Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Customer Action Code", FieldNo("Customer Action Code"));
                    end;
                }
                field("Lock POS Action Code"; "Lock POS Action Code")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = LockActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Lock POS Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Lock POS Action Code", FieldNo("Lock POS Action Code"));
                    end;
                }
                field("Unlock POS Action Code"; "Unlock POS Action Code")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = UnlockActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Unlock POS Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Unlock POS Action Code", FieldNo("Unlock POS Action Code"));
                    end;
                }
                field("OnBeforePaymentView Action"; "OnBeforePaymentView Action")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = OnBeforePaymentViewActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the On Before Payment View Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("OnBeforePaymentView Action", FieldNo("OnBeforePaymentView Action"));
                    end;
                }
                field("Idle Timeout Action Code"; "Idle Timeout Action Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Idle Timeout Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Idle Timeout Action Code", FieldNo("Idle Timeout Action Code"));
                    end;
                }
                field("Admin Menu Action Code"; "Admin Menu Action Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admin Menu Action Code field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit("Admin Menu Action Code", FieldNo("Admin Menu Action Code"));
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Refresh Invalid Action Parameters")
            {
                Caption = 'Refresh Invalid Action Parameters';
                Enabled = RefreshEnabled;
                Image = RefreshText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Refresh Invalid Action Parameters action';

                trigger OnAction()
                begin
                    RefreshInvalidActions();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        UpdateActionsStyles();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateActionsStyles();
    end;

    trigger OnOpenPage()
    var
        POSAction: Record "NPR POS Action";
    begin
        if not Find then
            Insert;

        POSAction.DiscoverActions();
    end;

    var
        LoginActionRefreshNeeded: Boolean;
        TextEnterActionRefreshNeeded: Boolean;
        ItemInsertActionRefreshNeeded: Boolean;
        PaymentActionRefreshNeeded: Boolean;
        CustomerActionRefreshNeeded: Boolean;
        LockActionRefreshNeeded: Boolean;
        UnlockActionRefreshNeeded: Boolean;
        OnBeforePaymentViewActionRefreshNeeded: Boolean;
        RefreshEnabled: Boolean;

    local procedure UpdateActionsStyles()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        LoginActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Login Action Code"), "Login Action Code");
        TextEnterActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Text Enter Action Code"), "Text Enter Action Code");
        ItemInsertActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Item Insert Action Code"), "Item Insert Action Code");
        PaymentActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Payment Action Code"), "Payment Action Code");
        CustomerActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Customer Action Code"), "Customer Action Code");
        LockActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Lock POS Action Code"), "Lock POS Action Code");
        UnlockActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("Unlock POS Action Code"), "Unlock POS Action Code");
        OnBeforePaymentViewActionRefreshNeeded := ParamMgt.RefreshParametersRequired(RecordId, '', FieldNo("OnBeforePaymentView Action"), "OnBeforePaymentView Action");

        RefreshEnabled :=
          LoginActionRefreshNeeded or TextEnterActionRefreshNeeded or ItemInsertActionRefreshNeeded or PaymentActionRefreshNeeded or CustomerActionRefreshNeeded or
          LockActionRefreshNeeded or UnlockActionRefreshNeeded or OnBeforePaymentViewActionRefreshNeeded;
    end;

    local procedure RefreshInvalidActions()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if LoginActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Login Action Code"), "Login Action Code");

        if TextEnterActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Text Enter Action Code"), "Text Enter Action Code");

        if ItemInsertActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Item Insert Action Code"), "Item Insert Action Code");

        if PaymentActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Payment Action Code"), "Payment Action Code");

        if CustomerActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Customer Action Code"), "Customer Action Code");

        if LockActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Lock POS Action Code"), "Lock POS Action Code");

        if UnlockActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("Unlock POS Action Code"), "Unlock POS Action Code");

        if OnBeforePaymentViewActionRefreshNeeded then
            ParamMgt.RefreshParameters(RecordId, '', FieldNo("OnBeforePaymentView Action"), "OnBeforePaymentView Action");
    end;
}

