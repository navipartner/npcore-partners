codeunit 6060124 "NPR TM Sales Order Post. Auto"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        PostTicket: Boolean;
        PostMember: Boolean;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        if SalesHeader.IsEmpty() then
            exit;

        // Expected "Parmeter String" like: SKIP_PAYMENT,POST_TICKET,POST_MEMBER 
        JQParamStrMgt.Parse(Rec."Parameter String");

        SkipPaymentCheck := JQParamStrMgt.GetBoolean(ParamSkipPayment());
        PostTicket := JQParamStrMgt.GetBoolean(ParamPostTicket());
        PostMember := JQParamStrMgt.GetBoolean(ParamPostMember());

        if SalesHeader.FindSet() then
            repeat
                if PostTicket then
                    PostTicketSalesOrder(SalesHeader);

                if PostMember then
                    PostMemberSalesOrder(SalesHeader);
            until SalesHeader.Next() = 0;
    end;

    var
        SkipPaymentCheck: Boolean;

    procedure ParamSkipPayment(): Text
    begin
        exit('SKIP_PAYMENT');
    end;

    procedure ParamPostTicket(): Text
    begin
        exit('POST_TICKET');
    end;

    procedure ParamPostMember(): Text
    begin
        exit('POST_MEMBER');
    end;

    local procedure PostTicketSalesOrder(SalesHeader: Record "Sales Header")
    begin
        if not HasTicketItem(SalesHeader) then
            exit;

        if HasNonTicketItem(SalesHeader) then
            exit;

        PostSalesOrder(SalesHeader);
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
        if SalesLine.FindSet() then
            repeat
                if Item.Get(SalesLine."No.") and (Item."NPR Ticket Type" <> '') then
                    exit(true);
            until SalesLine.Next() = 0;

        exit(false);
    end;

    local procedure HasNonTicketItem(SalesHeader: Record "Sales Header"): Boolean
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.FindSet() then
            repeat
                if Item.Get(SalesLine."No.") and (Item."NPR Ticket Type" = '') then
                    exit(true);
            until SalesLine.Next() = 0;

        exit(false);
    end;

    local procedure PostMemberSalesOrder(SalesHeader: Record "Sales Header")
    begin
        if not HasMemberItem(SalesHeader) then
            exit;

        PostSalesOrder(SalesHeader);
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
        if SalesLine.FindSet() then
            repeat
                if MMMembershipSalesSetup.Get(MMMembershipSalesSetup.Type::ITEM, SalesLine."No.") then
                    exit(true);

                MMMembershipAlterationSetup.SetFilter("Sales Item No.", SalesLine."No.");
                if MMMembershipAlterationSetup.FindFirst() then
                    exit(true)
            until SalesLine.Next() = 0;

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
        if not PaymentLine.IsEmpty() then
            exit(true);

        PaymentLine.SetRange("Payment Gateway Code");

        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        exit(PaymentLine.IsEmpty());
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
        Commit();
    end;
}