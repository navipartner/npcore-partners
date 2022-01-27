page 6150707 "NPR POS Named Actions Profile"
{
    Extensible = False;
    Caption = 'POS Named Actions Profile';
    PageType = Card;
    SourceTable = "NPR POS Setup";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Primary Key"; Rec."Primary Key")
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Actions")
            {
                field("Login Action Code"; Rec."Login Action Code")
                {

                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = LoginActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Login Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Login Action Code", Rec.FieldNo("Login Action Code"));
                    end;
                }
                field("Text Enter Action Code"; Rec."Text Enter Action Code")
                {

                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = TextEnterActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Text Enter Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Text Enter Action Code", Rec.FieldNo("Text Enter Action Code"));
                    end;
                }
                field("Item Insert Action Code"; Rec."Item Insert Action Code")
                {

                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = ItemInsertActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Item Insert Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Item Insert Action Code", Rec.FieldNo("Item Insert Action Code"));
                    end;
                }
                field("Payment Action Code"; Rec."Payment Action Code")
                {

                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = PaymentActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Payment Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Payment Action Code", Rec.FieldNo("Payment Action Code"));
                    end;
                }
                field("Customer Action Code"; Rec."Customer Action Code")
                {

                    AssistEdit = true;
                    Style = Unfavorable;
                    StyleExpr = CustomerActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Customer Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Customer Action Code", Rec.FieldNo("Customer Action Code"));
                    end;
                }
                field("Lock POS Action Code"; Rec."Lock POS Action Code")
                {

                    Style = Unfavorable;
                    StyleExpr = LockActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Lock POS Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Lock POS Action Code", Rec.FieldNo("Lock POS Action Code"));
                    end;
                }
                field("Unlock POS Action Code"; Rec."Unlock POS Action Code")
                {

                    Style = Unfavorable;
                    StyleExpr = UnlockActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the Unlock POS Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Unlock POS Action Code", Rec.FieldNo("Unlock POS Action Code"));
                    end;
                }
                field("OnBeforePaymentView Action"; Rec."OnBeforePaymentView Action")
                {

                    Style = Unfavorable;
                    StyleExpr = OnBeforePaymentViewActionRefreshNeeded;
                    ToolTip = 'Specifies the value of the On Before Payment View Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."OnBeforePaymentView Action", Rec.FieldNo("OnBeforePaymentView Action"));
                    end;
                }
                field("Idle Timeout Action Code"; Rec."Idle Timeout Action Code")
                {

                    ToolTip = 'Specifies the value of the Idle Timeout Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Idle Timeout Action Code", Rec.FieldNo("Idle Timeout Action Code"));
                    end;
                }
                field("Admin Menu Action Code"; Rec."Admin Menu Action Code")
                {

                    ToolTip = 'Specifies the value of the Admin Menu Action Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEdit(Rec."Admin Menu Action Code", Rec.FieldNo("Admin Menu Action Code"));
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

                ToolTip = 'Executes the Refresh Invalid Action Parameters action';
                ApplicationArea = NPRRetail;

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
        LoginActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Login Action Code"), Rec."Login Action Code");
        TextEnterActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Text Enter Action Code"), Rec."Text Enter Action Code");
        ItemInsertActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Item Insert Action Code"), Rec."Item Insert Action Code");
        PaymentActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Payment Action Code"), Rec."Payment Action Code");
        CustomerActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Customer Action Code"), Rec."Customer Action Code");
        LockActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Lock POS Action Code"), Rec."Lock POS Action Code");
        UnlockActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("Unlock POS Action Code"), Rec."Unlock POS Action Code");
        OnBeforePaymentViewActionRefreshNeeded := ParamMgt.RefreshParametersRequired(Rec.RecordId, '', Rec.FieldNo("OnBeforePaymentView Action"), Rec."OnBeforePaymentView Action");

        RefreshEnabled :=
          LoginActionRefreshNeeded or TextEnterActionRefreshNeeded or ItemInsertActionRefreshNeeded or PaymentActionRefreshNeeded or CustomerActionRefreshNeeded or
          LockActionRefreshNeeded or UnlockActionRefreshNeeded or OnBeforePaymentViewActionRefreshNeeded;
    end;

    local procedure RefreshInvalidActions()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        if LoginActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Login Action Code"), Rec."Login Action Code");

        if TextEnterActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Text Enter Action Code"), Rec."Text Enter Action Code");

        if ItemInsertActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Item Insert Action Code"), Rec."Item Insert Action Code");

        if PaymentActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Payment Action Code"), Rec."Payment Action Code");

        if CustomerActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Customer Action Code"), Rec."Customer Action Code");

        if LockActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Lock POS Action Code"), Rec."Lock POS Action Code");

        if UnlockActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("Unlock POS Action Code"), Rec."Unlock POS Action Code");

        if OnBeforePaymentViewActionRefreshNeeded then
            ParamMgt.RefreshParameters(Rec.RecordId, '', Rec.FieldNo("OnBeforePaymentView Action"), Rec."OnBeforePaymentView Action");
    end;
}

