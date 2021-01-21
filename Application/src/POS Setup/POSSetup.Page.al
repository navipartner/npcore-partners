page 6150707 "NPR POS Setup"
{
    // NPR5.37/TSA /20171024 CASE 293905 Added "Lock POS Action Code", "Unlock POS Action Code"
    // NPR5.39/TSA /20180126 CASE 303399 Added "OnBeforePaymentView Action"
    // NPR5.40/VB  /20180228 CASE 306347  Replacing BLOB-based parameters with phyisical-table parameters.
    // NPR5.54/TSA /20200219 CASE 391850 Added Description
    // NPR5.54/TSA /20200220 CASE 392121 Added "Idle Timeout Action Code"
    // NPR5.55/TSA /20200417 CASE 400734 Added "Admin Menu Action Code"

    Caption = 'POS Setup';
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "NPR POS Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Login Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Login Action Code", FieldNo("Login Action Code"));
                        //+NPR5.40 [306347]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [306347]
                        //CurrPage.SAVERECORD();
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Text Enter Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Text Enter Action Code", FieldNo("Text Enter Action Code"));
                        //+NPR5.40 [306347]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [306347]
                        //CurrPage.SAVERECORD();
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Item Insert Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Item Insert Action Code", FieldNo("Item Insert Action Code"));
                        //+NPR5.40 [306347]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [306347]
                        //CurrPage.SAVERECORD();
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Payment Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Payment Action Code", FieldNo("Payment Action Code"));
                        //+NPR5.40 [306347]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [306347]
                        //CurrPage.SAVERECORD();
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Customer Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Customer Action Code", FieldNo("Customer Action Code"));
                        //+NPR5.40 [306347]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [306347]
                        //CurrPage.SAVERECORD();
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Lock POS Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Lock POS Action Code", FieldNo("Lock POS Action Code"));
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("Unlock POS Action Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("Unlock POS Action Code", FieldNo("Unlock POS Action Code"));
                        //+NPR5.40 [306347]
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
                        //-NPR5.40 [306347]
                        //IF AssistEdit(FIELDNO("OnBeforePaymentView Parameters")) THEN
                        //  CurrPage.SAVERECORD();
                        AssistEdit("OnBeforePaymentView Action", FieldNo("OnBeforePaymentView Action"));
                        //+NPR5.40 [306347]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [306347]
                        //CurrPage.SAVERECORD();
                        //+NPR5.40 [306347]
                    end;
                }
                field("Idle Timeout Action Code"; "Idle Timeout Action Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Idle Timeout Action Code field';

                    trigger OnAssistEdit()
                    begin

                        //-NPR5.54 [392121]
                        AssistEdit("Idle Timeout Action Code", FieldNo("Idle Timeout Action Code"));
                        //+NPR5.54 [392121]
                    end;
                }
                field("Admin Menu Action Code"; "Admin Menu Action Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admin Menu Action Code field';

                    trigger OnAssistEdit()
                    begin

                        //-NPR5.55 [400734]
                        AssistEdit("Admin Menu Action Code", FieldNo("Admin Menu Action Code"));
                        //-NPR5.55 [400734]
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
                    //-NPR5.40 [306347]
                    RefreshInvalidActions();
                    //+NPR5.40 [306347]
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        //-NPR5.40 [306347]
        UpdateActionsStyles();
        //+NPR5.40 [306347]
    end;

    trigger OnAfterGetRecord()
    begin
        //-NPR5.40 [306347]
        UpdateActionsStyles();
        //+NPR5.40 [306347]
    end;

    trigger OnOpenPage()
    var
        POSAction: Record "NPR POS Action";
    begin
        if not Find then
            Insert;

        //-NPR5.40 [306347]
        POSAction.DiscoverActions();
        //+NPR5.40 [306347]
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
        //-NPR5.40 [306347]
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
        //+NPR5.40 [306347]
    end;

    local procedure RefreshInvalidActions()
    var
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        //-NPR5.40 [306347]
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
        //+NPR5.40 [306347]
    end;
}

