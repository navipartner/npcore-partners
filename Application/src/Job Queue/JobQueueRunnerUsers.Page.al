page 6248219 "NPR Job Queue Runner Users"
{
    Extensible = false;
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;
    Caption = 'Job Queue Runner Users';
    PageType = List;
    SourceTable = "NPR Job Queue Runner User";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the client ID of the job queue runner user.';
                    StyleExpr = _StyleExprTxt;
                }
                field("JQ Runner User Name"; Rec."JQ Runner User Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the job queue runner user.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Failed Attempts"; Rec."Failed Attempts")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the number of failed attempts by the job queue runner user. If this value exceeds 9, the job queue runner user is considered inactive. Run the "Reset Failed Attempts" action to reset this value.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Last Success Date Time"; Rec."Last Success Date Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the job queue runner user was last successfully used by the external refresher.';
                    StyleExpr = _StyleExprTxt;
                }
                field("Last Error Text"; Rec."Last Error Text")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the last error text for the job queue runner user if the last attempt to execute the refreshing routine using this user was unsuccessful. This field is cleared after a successful run.';
                    StyleExpr = _StyleExprTxt;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Refresh List';
                Image = Refresh;
                Tooltip = 'Refresh the list of job queue runner users.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    UpdateList();
                    CurrPage.Update(false);
                end;
            }
            action("Reset Failed Attempts")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Reset Failed Attempts';
                Image = ResetStatus;
                Tooltip = 'Reset the "Failed Attempts" counter for the selected job queue runner.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
                    SuccessfulResetLbl: Label 'Successfully reset Failed Attempts value for Entra App "%1"';
                begin
                    if Rec."Failed Attempts" = 0 then
                        exit;
                    ExternalJQRefresherMgt.ResetJQRunnerUserFailedAttempts(Rec);
                    CurrPage.Update(false);
                    Message(SuccessfulResetLbl, Rec."Client ID");
                end;
            }
            action("Show Last Error Text")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Last Error Text';
                Image = ErrorLog;
                Tooltip = 'Show the last error text.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    NoErrorLbl: Label 'No error message has been recorded for this user.';
                begin
                    if Rec."Last Error Text" <> '' then
                        Message(Rec."Last Error Text")
                    else
                        Message(NoErrorLbl);
                end;
            }
            action("Show Entra App Card")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Entra App Card';
                Image = Navigate;
                ToolTip = 'Opens related Microsoft entra application entry card.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    AADApplication: Record "AAD Application";
                    EntraAppDoesNotExistLbl: Label 'Entra App with Client ID "%1" does not exist in Business Central.';
                begin
                    if not AADApplication.Get(Rec."Client ID") then
                        Error(EntraAppDoesNotExistLbl, Rec."Client ID");
                    Page.Run(Page::"AAD Application Card", AADApplication);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        UpdateList();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Failed Attempts" < 10 then
            _StyleExprTxt := 'Standard'
        else
            _StyleExprTxt := 'Unfavorable';
    end;

    local procedure UpdateList()
    var
        ExternalJQRefresherMgt: Codeunit "NPR External JQ Refresher Mgt.";
    begin
        ExternalJQRefresherMgt.UpdateJQRunnerUsersList(Rec, true);
    end;

    var
        _StyleExprTxt: Text[50];
}
