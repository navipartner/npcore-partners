codeunit 6060124 "NPR TM Sales Order Post. Auto"
{
    TableNo = "NPR Task Line";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.IsEmpty then
            exit;
        if GetParameterBool('SKIP_PAYMENT') then
            SkipPaymentCheck := true;
        if SalesHeader.FindSet then
            repeat
                if GetParameterBool('POST_TICKET') then
                    PostTicketSalesOrder(SalesHeader);
                if GetParameterBool('POST_MEMBER') then
                    PostMemberSalesOrder(SalesHeader);
            until SalesHeader.Next = 0;
    end;

    var
        SkipPaymentCheck: Boolean;

    local procedure "--- Post Ticket"()
    begin
    end;

    local procedure PostTicketSalesOrder(SalesHeader: Record "Sales Header")
    begin
        if not HasTicketItem(SalesHeader) then
            exit;
        //-TM1.32 [317235]
        if HasNonTicketItem(SalesHeader) then
            exit;
        //+TM1.32 [317235]
        //-TM1.28  [305008]
        PostSalesOrder(SalesHeader);
        //+TM1.28  [305008]
    end;

    local procedure HasTicketItem(SalesHeader: Record "Sales Header"): Boolean
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.IsEmpty then
            exit(false);

        SalesLine.FindSet;
        repeat
            if Item.Get(SalesLine."No.") and (Item."NPR Ticket Type" <> '') then
                exit(true);
        until SalesLine.Next = 0;

        exit(false);
    end;

    local procedure HasNonTicketItem(SalesHeader: Record "Sales Header"): Boolean
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        //-TM1.32 [317235]
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.IsEmpty then
            exit(false);

        SalesLine.FindSet;
        repeat
            if Item.Get(SalesLine."No.") and (Item."NPR Ticket Type" = '') then
                exit(true);
        until SalesLine.Next = 0;

        exit(false);
        //+TM1.32 [317235]
    end;

    local procedure "----Post Member"()
    begin
    end;

    local procedure PostMemberSalesOrder(SalesHeader: Record "Sales Header")
    begin
        if not HasMemberItem(SalesHeader) then
            exit;
        //-TM1.28  [305008]
        PostSalesOrder(SalesHeader);
        //+TM1.28  [305008]
    end;

    local procedure HasMemberItem(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        MMMembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MMMembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.IsEmpty then
            exit(false);

        SalesLine.FindSet;
        repeat
            //-TM1.25 [292336]
            //IF MMMembershipSalesSetup.GET( SalesLine.Type::Item,SalesLine."No.") THEN
            if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, SalesLine."No.") then
                //+TM1.25 [292663]
                exit(true);
            MMMembershipAlterationSetup.SetFilter("Sales Item No.", SalesLine."No.");
            if MMMembershipAlterationSetup.FindFirst then
                exit(true)
        until SalesLine.Next = 0;

        exit(false);
    end;


    local procedure PaymentIsAuthorized(SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        if SkipPaymentCheck then
            exit;
        PaymentLine.SetRange("Document Table No.", DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if PaymentLine.FindFirst then
            exit(true);

        PaymentLine.SetRange("Payment Gateway Code");

        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        exit(PaymentLine.IsEmpty);
    end;

    local procedure PostSalesOrder(SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        if not SkipPaymentCheck then
            if not PaymentIsAuthorized(SalesHeader) then
                exit;
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Clear(SalesPost);
        if SalesPost.Run(SalesHeader) then;
        Commit;
    end;
}

