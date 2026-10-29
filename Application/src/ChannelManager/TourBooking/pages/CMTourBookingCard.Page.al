page 6150983 "NPR CMTourBookingCard"
{
    Extensible = false;
    Caption = 'Tour Booking';
    PageType = Document;
    SourceTable = "NPR CMOrder";
    UsageCategory = None;
    InsertAllowed = false;
    RefreshOnActivate = true;
    DataCaptionExpression = Rec.GetDataCaption();

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = _IsEditable;

                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Booking Reference';
                    ToolTip = 'The booking reference, assigned from the partner''s number series when the booking is created. The customer shows it at pick-up.';
                    Editable = false;
                }
                field(PartnerName; _PartnerName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Partner';
                    ToolTip = 'The Tour Booking partner the booking belongs to. It sets the number series, the wallet design and how the booking is sent to the customer.';
                    Editable = false;
                }
                field(SellToCustomerNo; Rec.SellToCustomerNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The customer the booking is for. Choosing a customer copies in its name, email and language.';
                    ShowMandatory = true;
                }
                field(SellToOrderReference; Rec.SellToOrderReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The order reference we give the customer for the booking. It is unique per channel manager partner and defaults to the booking reference.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if (Rec.SellToOrderReference = '') then
                            Rec.SellToOrderReference := Rec.DocumentNo;
                        _TourBookingMgt.ValidateUniqueOrderReference(Rec);
                    end;
                }
                field(SellToName; Rec.SellToName)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The name on the booking. Lines without a name use it.';
                }
                field(SellToEmail; Rec.SellToEmail)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The email address the order confirmation and the wallets are sent to. Lines without an email address use it. Required when the partner sends bookings by NP Mail.';
                    ShowMandatory = _IsMailDistributed;
                }
                field(SellToLanguage; Rec.SellToLanguage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The language of the mails and the wallets. Lines without a language use it.';
                }
                field(PaymentOption; Rec.PaymentOption)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Prepaid: the booking is confirmed when it is issued. Invoice: the booking is confirmed and invoiced when it is issued. Pay at Pick-up: the booking is confirmed when it is paid at pick-up.';

                    trigger OnValidate()
                    begin
                        UpdateControls();
                    end;
                }
                field(PaymentReference; Rec.PaymentReference)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The reference of the payment for a prepaid booking. For an invoiced booking, it is the booking reference, which the sales invoice carries. For a booking paid at pick-up, it shows the POS receipt no. once the booking is paid. It opens the document the payment is on.';
                    Editable = _IsPrepaid;
                    ShowMandatory = _IsPrepaid;

                    trigger OnDrillDown()
                    begin
                        _TourBookingMgt.ShowPaymentDocument(Rec);
                    end;
                }
                field(InvoiceStatus; _InvoiceStatus)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Invoice Status';
                    ToolTip = 'The state of the sales invoice of the booking. It opens the invoice.';
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The state of the booking. It controls how the booking can be handled.';
                    StyleExpr = _StatusStyle;
                    Editable = false;
                }
                field(StatusMessage; Rec.StatusMessage)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Why the last attempt to issue the booking failed.';
                    Editable = false;
                    Importance = Additional;
                }
                field(Manifest; GetManifestLabel())
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Manifest';
                    ToolTip = 'Opens the manifest of the confirmed booking: its wallets, rendered with the partner''s wallet design layout.';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        if (Rec.ManifestUrl <> '') then
                            Hyperlink(Rec.ManifestUrl);
                    end;
                }
            }
            part(Lines; "NPR CMTourBookingLines")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Lines';
                SubPageLink = OrderId = field(OrderId);
                UpdatePropagation = Both;
                Editable = _IsEditable;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(IssueOrder)
            {
                Caption = 'Issue';
                Image = ReleaseDoc;
                ToolTip = 'Issue the assets of the booking. A prepaid booking is confirmed when it is issued, and an invoiced booking is also invoiced; a booking paid at pick-up is confirmed when it is paid.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Enabled = _IsEditable;

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    Distribution: Codeunit "NPR CMOrderDistribution";
                    HadOrderConfirmation: Boolean;
                    ResendQst: Label 'An order confirmation for %1 has already been sent. Send a new one to %2?', Comment = '%1 = booking reference, %2 = email address';
                begin
                    CurrPage.SaveRecord();
                    HadOrderConfirmation := Distribution.HasOrderConfirmation(Rec);
                    if (not _TourBookingMgt.IssueOrder(Rec)) then
                        Message('%1', Rec.StatusMessage)
                    else begin
                        if ((HadOrderConfirmation) and (Rec.Status = Rec.Status::Draft)) then
                            if (Confirm(ResendQst, true, Rec.DocumentNo, Rec.SellToEmail)) then
                                Distribution.QueueNewOrderConfirmation(Rec);
                        if (Rec.PaymentOption = Rec.PaymentOption::Invoice) then
                            if (_TourBookingMgt.FindSalesInvoice(Rec, SalesHeader)) then
                                Page.Run(Page::"Sales Invoice", SalesHeader);
                    end;
                    CurrPage.Update(false);
                end;
            }
            action(ReopenOrder)
            {
                Caption = 'Reopen';
                Image = ReOpen;
                ToolTip = 'Reopen a Draft booking to change it. Its assets are deleted and the capacity is released. Issue the booking again when you are done.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Enabled = _CanReopen;

                trigger OnAction()
                var
                    ReopenQst: Label 'Reopen booking %1?\\All assets will be deleted and the capacity will be released.', Comment = '%1 = booking reference';
                begin
                    if (not Confirm(ReopenQst, false, Rec.DocumentNo)) then
                        exit;
                    _TourBookingMgt.ReopenOrder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(SendOrderConfirmation)
            {
                Caption = 'Send Order Confirmation';
                Image = SendMail;
                ToolTip = 'Send a new order confirmation to the customer.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Enabled = _IsDraft or _IsIssued;

                trigger OnAction()
                var
                    Distribution: Codeunit "NPR CMOrderDistribution";
                    QueuedMsg: Label 'A new order confirmation has been queued for %1.', Comment = '%1 = email address';
                begin
                    Distribution.QueueNewOrderConfirmation(Rec);
                    Message(QueuedMsg, Rec.SellToEmail);
                end;
            }
            action(ConfirmPaidOrder)
            {
                Caption = 'Confirm Paid Booking';
                Image = Confirm;
                ToolTip = 'Confirm a Draft booking whose lines have all been paid in the POS. The POS confirms the booking when the sale ends; use this when that did not happen.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Enabled = _IsDraft;

                trigger OnAction()
                var
                    NotPaidMsg: Label 'The booking cannot be confirmed yet, because not all of its lines have been paid.';
                begin
                    if (not _TourBookingMgt.ConfirmOrder(Rec)) then
                        Message(NotPaidMsg);
                    CurrPage.Update(false);
                end;
            }
            action(CancelOrder)
            {
                Caption = 'Cancel';
                Image = Cancel;
                ToolTip = 'Cancel the booking. Its content is removed and the capacity is released.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Enabled = _CanRelease;

                trigger OnAction()
                var
                    CancelQst: Label 'Cancel booking %1? All assets will be deleted.', Comment = '%1 = booking reference';
                begin
                    if (not Confirm(CancelQst, false, Rec.DocumentNo)) then
                        exit;
                    _TourBookingMgt.CancelOrder(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ClearPersonalData)
            {
                Caption = 'Clear Personal Data';
                Image = ClearLog;
                ToolTip = 'Remove the personal data from the booking: the names are cleared and the email addresses are replaced by ones that cannot receive mail. The clear follows through to the tickets and wallets issued from the booking and to its mails, and mails not yet sent are dropped. The booking and payment references are kept. A cancelled booking can be cleared at any time, an issued booking from six months after its last visit. Irreversible.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Enabled = _IsIssued or _IsCancelled;

                trigger OnAction()
                var
                    Order: Record "NPR CMOrder";
                begin
                    Order := Rec;
                    Order.SetRecFilter();
                    _TourBookingMgt.AnonymizeBookings(Order);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(SalesInvoice)
            {
                Caption = 'Sales Invoice';
                Image = Invoice;
                ToolTip = 'Open the sales invoice of the booking, or create it when there is none.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Visible = _IsInvoice;
                Enabled = _IsIssued;

                trigger OnAction()
                begin
                    _TourBookingMgt.ShowPaymentDocument(Rec);
                end;
            }
            action(Wallets)
            {
                Caption = 'Wallets';
                Image = ItemGroup;
                ToolTip = 'Show the wallets issued for this booking.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                trigger OnAction()
                var
                    OrderWallet: Record "NPR CMOrderWallet";
                begin
                    OrderWallet.SetFilter(OrderId, '=%1', Rec.OrderId);
                    Page.Run(Page::"NPR CMOrderWallets", OrderWallet);
                end;
            }
            action(Notifications)
            {
                Caption = 'Mails';
                Image = Email;
                ToolTip = 'Show the order confirmation and wallet mails queued for this booking.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                trigger OnAction()
                var
                    NotifEntry: Record "NPR Digital Notification Entry";
                begin
                    NotifEntry.SetCurrentKey("Source Document Id", "Notification Type");
                    NotifEntry.SetFilter("Source Document Id", '=%1', Rec.OrderId);
                    Page.Run(Page::"NPR Digital Notif. Entries", NotifEntry);
                end;
            }
            action(OrderConfirmationData)
            {
                Caption = 'Order Confirmation Data';
                Image = XMLFile;
                ToolTip = 'Show the data the order confirmation template receives for this booking.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                trigger OnAction()
                var
                    Distribution: Codeunit "NPR CMOrderDistribution";
                begin
                    Message('%1', Distribution.GetOrderConfirmationData(Rec));
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(IssueOrder_Promoted; IssueOrder) { }
                actionref(ReopenOrder_Promoted; ReopenOrder) { }
                actionref(CancelOrder_Promoted; CancelOrder) { }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        _TourBookingMgt.DeleteOrderContent(Rec);
        exit(true);
    end;

    trigger OnAfterGetRecord()
    begin
        _InvoiceStatus := '';
        if ((Rec.PaymentOption = Rec.PaymentOption::Invoice) and (Rec.Status = Rec.Status::Issued)) then
            _InvoiceStatus := _TourBookingMgt.GetSalesInvoiceStatus(Rec);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateControls();
    end;

    local procedure UpdateControls()
    var
        PartnerSetup: Record "NPR CMPartnerSetup";
    begin
        if (IsNullGuid(Rec.PartnerId)) then
            exit;

        PartnerSetup.Get(Rec.PartnerId);
        _PartnerName := PartnerSetup.Name;
        _StatusStyle := Rec.GetStatusStyle();

        _IsEditable := _TourBookingMgt.IsEditable(Rec);
        _IsDraft := Rec.Status = Rec.Status::Draft;
        _IsIssued := Rec.Status = Rec.Status::Issued;
        _IsCancelled := Rec.Status = Rec.Status::Cancelled;
        _CanRelease := _TourBookingMgt.CanReleaseOrder(Rec);
        _CanReopen := _IsDraft and _CanRelease;
        _IsPrepaid := Rec.PaymentOption = Rec.PaymentOption::Prepaid;
        _IsInvoice := Rec.PaymentOption = Rec.PaymentOption::Invoice;
        _IsMailDistributed := _TourBookingMgt.IsMailDistributed(Rec.PartnerId);
    end;

    local procedure GetManifestLabel(): Text[30]
    var
        ClickToOpenLbl: Label 'Click to open';
    begin
        if (Rec.ManifestUrl = '') then
            exit('');
        exit(ClickToOpenLbl);
    end;

    var
        _TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        _PartnerName: Text[100];
        _StatusStyle: Text;
        _IsEditable: Boolean;
        _CanRelease: Boolean;
        _CanReopen: Boolean;
        _IsDraft: Boolean;
        _IsIssued: Boolean;
        _IsCancelled: Boolean;
        _IsPrepaid: Boolean;
        _IsInvoice: Boolean;
        _InvoiceStatus: Text;
        _IsMailDistributed: Boolean;
}
