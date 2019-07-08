codeunit 6014462 "Sales-Post Action Mgt"
{
    // NPR5.36/THRO/20170908 CASE 285645 Subscribers for Pdf2Nav Posting


    trigger OnRun()
    begin
    end;

    var
        StdActionDisabledMsg: Label 'This Action is disabled by setup. Please use ''Post and Pdf2Nav''';
        Pdf2NavActionDisabledMsg1: Label 'This Action is disabled by setup. Please use ''Post and Print'' or ''Post and Email ''';
        Pdf2NavActionDisabledMsg2: Label 'This Action is disabled by setup. Please use ''Post and Send'', ''Post and Print'' or ''Post and Email ''';
        Pdf2NavActionDisabledMsg3: Label 'This Action is disabled by setup. Please use ''Post and Print''';

    [EventSubscriber(ObjectType::Page, 42, 'OnBeforeActionEvent', 'Action76', true, true)]
    local procedure Page42OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnBeforeActionEvent', 'Action29', true, true)]
    local procedure Page42OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page42OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 42, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page42OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnBeforeActionEvent', 'Action72', true, true)]
    local procedure Page43OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnBeforeActionEvent', 'Action17', true, true)]
    local procedure Page43OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page43OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page43OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 43, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page43OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnBeforeActionEvent', 'Action62', true, true)]
    local procedure Page44OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnBeforeActionEvent', 'Action17', true, true)]
    local procedure Page44OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page44OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page44OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 44, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page44OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnBeforeActionEvent', 'Action62', true, true)]
    local procedure Page6630OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6630OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg3);
    end;

    [EventSubscriber(ObjectType::Page, 6630, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6630OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnBeforeActionEvent', 'Action52', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnBeforeActionEvent', 'Action8', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9301OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 9301, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9301OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnBeforeActionEvent', 'Action53', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnBeforeActionEvent', 'Action8', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnBeforeActionEvent', 'PostAndSend', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndSend(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9302OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg2);
    end;

    [EventSubscriber(ObjectType::Page, 9302, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9302OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9304, 'OnBeforeActionEvent', 'Action51', true, true)]
    local procedure Page9304OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9304, 'OnBeforeActionEvent', 'Action12', true, true)]
    local procedure Page9304OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9304, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9304OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 9304, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9304OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 9305, 'OnBeforeActionEvent', 'Action1102601004', true, true)]
    local procedure Page9305OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9305, 'OnBeforeActionEvent', 'Action14', true, true)]
    local procedure Page9305OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 9305, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9305OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 9305, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page9305OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnBeforeActionEvent', 'Action76', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndPrint(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnBeforeActionEvent', 'Action29', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndEmail(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Pdf2Nav Only" then
                Error(StdActionDisabledMsg);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnBeforeActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6014518OnBeforeActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    var
        SalesPostandPdf2NavSetup: Record "Sales-Post and Pdf2Nav Setup";
    begin
        if SalesPostandPdf2NavSetup.Get then
            if SalesPostandPdf2NavSetup."Post and Send" = SalesPostandPdf2NavSetup."Post and Send"::"Std. NAV Only" then
                Error(Pdf2NavActionDisabledMsg1);
    end;

    [EventSubscriber(ObjectType::Page, 6014518, 'OnAfterActionEvent', 'PostAndSendPdf2Nav', true, true)]
    local procedure Page6014518OnAfterActionEventPostAndSendPdf2Nav(var Rec: Record "Sales Header")
    begin
        Rec.SendToPosting(Pdf2NavPostingCodeunitID);
    end;

    local procedure "---"()
    begin
    end;

    local procedure Pdf2NavPostingCodeunitID(): Integer
    begin
        exit(6014463);
    end;
}

