codeunit 6060124 "TM Sales Order Posting Auto"
{
    // TM1.23/TS  /20170529  CASE 243535 Automatic Posting of Member and Ticket Sales Order as Task in Task Queue
    // TM1.25/TS  /20171024  CASE 292663 Corrected Paramenter for Get function
    // TM1.28/TS  /20180220  CASE 305008 Added function to Post Gift Vouchers
    // TM1.30/TS  /20180403  CASE 305008 Enabled Post Gift Vouchers and added setting to enable it from Task Queue.
    // TM1.32/MHA /20180530  CASE 317235 Added function HasNonTicketItem() in PostTicketSalesOrder()
    // TM1.32/MHA /20180530  CASE 317207 Added IF/THEN around Codeunit.RUN in PostSalesOrder() as error on a single Sales Order should not stop the process
    // TM1.39/TS  /20181123  CASE 335243  Added parameters to Skip Payment Check and to Check SalesPerson Code

    TableNo = "Task Line";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetRange("Document Type",SalesHeader."Document Type"::Order);
        if SalesHeader.IsEmpty then
          exit;
        //-TM1.39 [335243]
        if GetParameterBool('SKIP_PAYMENT') then
          SkipPaymentCheck := true;
        //+TM1.39 [335243]
        if SalesHeader.FindSet then
          repeat
            //-TM1.28  [305008]
            if GetParameterBool('POST_TICKET') then
              PostTicketSalesOrder(SalesHeader);
            if GetParameterBool('POST_MEMBER') then
              PostMemberSalesOrder(SalesHeader);
            if GetParameterBool('POST_VOUCHER') then
              PostVouchers(SalesHeader);
            //+TM1.28  [305008]
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
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange(Type,SalesLine.Type::Item);
        SalesLine.SetFilter("No.",'<>%1','');
        if SalesLine.IsEmpty then
          exit(false);

        SalesLine.FindSet;
        repeat
          if Item.Get(SalesLine."No.") and (Item."Ticket Type" <> '') then
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
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange(Type,SalesLine.Type::Item);
        SalesLine.SetFilter("No.",'<>%1','');
        if SalesLine.IsEmpty then
          exit(false);

        SalesLine.FindSet;
        repeat
          if Item.Get(SalesLine."No.") and (Item."Ticket Type" = '') then
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
        MMMembershipSalesSetup: Record "MM Membership Sales Setup";
        MMMembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange(Type,SalesLine.Type::Item);
        SalesLine.SetFilter("No.",'<>%1','');
        if SalesLine.IsEmpty then
          exit(false);

        SalesLine.FindSet;
        repeat
          //-TM1.25 [292336]
          //IF MMMembershipSalesSetup.GET( SalesLine.Type::Item,SalesLine."No.") THEN
          if MMMembershipSalesSetup.Get( MMMembershipSalesSetup.Type::ITEM,SalesLine."No.") then
          //+TM1.25 [292663]
            exit(true);
          MMMembershipAlterationSetup.SetFilter("Sales Item No.",SalesLine."No.");
          if MMMembershipAlterationSetup.FindFirst then
            exit(true)
        until SalesLine.Next = 0;

        exit(false);
    end;

    local procedure "----Post Vouchers"()
    begin
    end;

    local procedure PostVouchers(SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        //-TM1.28  [305008]
        if not HasGiftVoucher(SalesHeader) then
          exit;
        PostSalesOrder(SalesHeader);
        //+TM1.28  [305008]
    end;

    local procedure HasGiftVoucher(SalesHeader: Record "Sales Header"): Boolean
    var
        SalesLine: Record "Sales Line";
        MagentoSetup: Record "Magento Setup";
    begin
        //-TM1.28  [305008]
        MagentoSetup.Get;
        SalesLine.SetRange("Document Type",SalesHeader."Document Type");
        SalesLine.SetRange("Document No.",SalesHeader."No.");
        SalesLine.SetRange(Type,SalesLine.Type::"G/L Account");
        SalesLine.SetRange(SalesLine."No.",MagentoSetup."Gift Voucher Account No.");
        exit(SalesLine.FindFirst);
        //+TM1.28  [305008]
    end;

    local procedure "---"()
    begin
    end;

    local procedure PaymentIsAuthorized(SalesHeader: Record "Sales Header"): Boolean
    var
        PaymentLine: Record "Magento Payment Line";
    begin
        //-TM1.39 [335243]
        if SkipPaymentCheck then
          exit;
        //+TM1.39 [335243]
        PaymentLine.SetRange("Document Table No.",DATABASE::"Sales Header");
        PaymentLine.SetRange("Document Type",SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.",SalesHeader."No.");
        if PaymentLine.FindFirst then
          exit(true);

        PaymentLine.SetRange("Payment Gateway Code");
        PaymentLine.SetRange("Payment Type",PaymentLine."Payment Type"::Voucher);
        if PaymentLine.IsEmpty then
          exit;

        PaymentLine.SetRange("Payment Type",PaymentLine."Payment Type"::"Payment Method");
        exit(PaymentLine.IsEmpty);
    end;

    local procedure PostSalesOrder(SalesHeader: Record "Sales Header")
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        //-TM1.39 [335243]
        if  not SkipPaymentCheck then
        //-TM1.28  [305008]
          if not PaymentIsAuthorized(SalesHeader) then
            exit;
        //+TM1.39 [335243]
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Clear(SalesPost);
        //-TM1.32 [317207]
        //SalesPost.RUN(SalesHeader);
        if SalesPost.Run(SalesHeader) then;
        Commit;
        //+TM1.32 [317207]
        //+TM1.28  [305008]
    end;
}

