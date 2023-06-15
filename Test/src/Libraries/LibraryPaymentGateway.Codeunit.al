codeunit 85127 "NPR Library - Payment Gateway"
{
    /// <summary>
    /// Create a new payment gateway with the given integration
    /// </summary>
    /// <param name="IntegrationType">The gateway integration</param>
    /// <returns>The code of the payment gateway created</returns>
    internal procedure CreatePaymentGateway(IntegrationType: Enum "NPR PG Integrations"): Code[10]
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        CreatePaymentGateway(IntegrationType, PaymentGateway);
        exit(PaymentGateway.Code);
    end;

    /// <summary>
    /// Create a new payment gateway
    /// </summary>
    internal procedure CreatePaymentGateway(IntegrationType: Enum "NPR PG Integrations"; var PaymentGateway: Record "NPR Magento Payment Gateway")
    var
        LibraryRandom: Codeunit "Library - Random";
    begin
        Clear(PaymentGateway);
        PaymentGateway.Init();
        PaymentGateway.Code := LibraryRandom.RandText(10);
        PaymentGateway."Integration Type" := IntegrationType;
        PaymentGateway."Enable Capture" := true;
        PaymentGateway."Enable Refund" := true;
        PaymentGateway."Enable Cancel" := true;
        PaymentGateway.Insert(true);
    end;

    /// <summary>
    /// Create a new Payment Line for the given Sales Header
    /// </summary>
    /// <param name="SalesHeader">Sales Header payment line should be assocaited with</param>
    /// <param name="GatewayCode">Payment Gateway to be used on the given payment line</param>
    internal procedure CreatePaymentLineForSalesHeader(SalesHeader: Record "Sales Header"; GatewayCode: Code[10])
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);
    end;

    /// <summary>
    /// Create a new Payment Line for the given Sales Header
    /// </summary>
    /// <param name="SalesHeader">Sales Header payment line should be assocaited with</param>
    /// <param name="GatewayCode">Payment Gateway to be used on the given payment line</param>
    /// <param name="PaymentLine">Payment Line record that should be operated upon</param>
    internal procedure CreatePaymentLineForSalesHeader(SalesHeader: Record "Sales Header"; GatewayCode: Code[10]; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        SalesHeader.SetAutoCalcFields("Amount Including VAT");
        SalesHeader.Find();

        CreatePaymentLineForDocument(Database::"Sales Header", SalesHeader."Document Type", SalesHeader."No.", GatewayCode, SalesHeader."Amount Including VAT", PaymentLine);
    end;

    /// <summary>
    /// Create a new Payment Line for the given Sales Invoice Header
    /// </summary>
    /// <param name="SalesInvHeader">Sales Invoice Header payment line should be assocaited with</param>
    /// <param name="GatewayCode">Payment Gateway to be used on the given payment line</param>
    internal procedure CreatePaymentLineForSalesInvoiceHeader(SalesInvHeader: Record "Sales Invoice Header"; GatewayCode: Code[10])
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        CreatePaymentLineForSalesInvoiceHeader(SalesInvHeader, GatewayCode, PaymentLine);
    end;

    /// <summary>
    /// Create a new Payment Line for the given Sales Invoice Header
    /// </summary>
    /// <param name="SalesInvHeader">Sales Invoice Header payment line should be assocaited with</param>
    /// <param name="GatewayCode">Payment Gateway to be used on the given payment line</param>
    /// <param name="PaymentLine">Payment Line record that should be operated upon</param>/// 
    internal procedure CreatePaymentLineForSalesInvoiceHeader(SalesInvHeader: Record "Sales Invoice Header"; GatewayCode: Code[10]; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        SalesInvHeader.SetAutoCalcFields("Amount Including VAT");
        SalesInvHeader.Find();

        CreatePaymentLineForDocument(Database::"Sales Invoice Header", SalesInvHeader."No.", GatewayCode, SalesInvHeader."Amount Including VAT", PaymentLine);
    end;

    local procedure CreatePaymentLineForDocument(DocumentTableNo: Integer; DocumentNo: Code[20]; GatewayCode: Code[10]; Amount: Decimal; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        CreatePaymentLineForDocument(DocumentTableNo, Enum::"Sales Document Type"::Quote, DocumentNo, GatewayCode, Amount, PaymentLine);
    end;

    /// <summary>
    /// Create a new Payment Line for the given Sales Credit Memo Header
    /// </summary>
    /// <param name="SalesCrMemoHeader">Sales Credit Memo Header payment line should be assocaited with</param>
    /// <param name="GatewayCode">Payment Gateway to be used on the given payment line</param>
    internal procedure CreatePaymentLineForSalesCrMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GatewayCode: Code[10])
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        CreatePaymentLineForSalesCrMemoHeader(SalesCrMemoHeader, GatewayCode, PaymentLine);
    end;

    /// <summary>
    /// Create a new Payment Line for the given Sales Credit Memo Header
    /// </summary>
    /// <param name="SalesCrMemoHeader">Sales Credit Memo Header payment line should be assocaited with</param>
    /// <param name="GatewayCode">Payment Gateway to be used on the given payment line</param>
    /// <param name="PaymentLine">Payment Line record that should be operated upon</param>/// 
    internal procedure CreatePaymentLineForSalesCrMemoHeader(SalesCrMemoHeader: Record "Sales Cr.Memo Header"; GatewayCode: Code[10]; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        SalesCrMemoHeader.SetAutoCalcFields("Amount Including VAT");
        SalesCrMemoHeader.Find();

        CreatePaymentLineForDocument(Database::"Sales Cr.Memo Header", SalesCrMemoHeader."No.", GatewayCode, SalesCrMemoHeader."Amount Including VAT", PaymentLine);
    end;

    local procedure CreatePaymentLineForDocument(DocumentTableNo: Integer; DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; GatewayCode: Code[10]; Amount: Decimal; var PaymentLine: Record "NPR Magento Payment Line")
    var
        LibERM: Codeunit "Library - ERM";
        LibRandom: Codeunit "Library - Random";
    begin
        PaymentLine.Init();
        PaymentLine."Document Table No." := DocumentTableNo;
        PaymentLine."Document Type" := DocumentType;
        PaymentLine."Document No." := DocumentNo;
        PaymentLine."No." := LibRandom.RandText(MaxStrLen(PaymentLine."No."));
        PaymentLine.Description := 'Test integration payment';
        PaymentLine.Amount := Amount;
        PaymentLine."Account Type" := PaymentLine."Account Type"::"G/L Account";
        PaymentLine."Account No." := LibERM.CreateGLAccountNoWithDirectPosting();
        PaymentLine."Payment Gateway Code" := GatewayCode;
        PaymentLine.Insert(true);
    end;
}