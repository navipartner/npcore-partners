page 6150984 "NPR CMTourBookingLines"
{
    Extensible = false;
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "NPR CMOrderLine";
    UsageCategory = None;
    AutoSplitKey = false;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The ticket or package item. It defines the content of the wallets.';
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        ExistingLine: Record "NPR CMOrderLine";
                    begin
                        if (Rec.ItemNo <> xRec.ItemNo) then
                            _TourBookingMgt.DeleteLineComponents(Rec);
                        _TourBookingMgt.ValidateLineItem(Rec);
                        _IsPackage := Rec.IsPackage;

                        _InheritFromLineNo := _TourBookingMgt.InheritVisitFromSameItem(Rec);
                        if (_InheritFromLineNo <> 0) then
                            if (ExistingLine.Get(Rec.OrderId, Rec.LineNo)) then begin
                                _TourBookingMgt.CopyLineComponents(Rec.OrderId, _InheritFromLineNo, Rec.LineNo);
                                _InheritFromLineNo := 0;
                            end;
                        UpdateLineInfo();
                    end;
                }
                field(ItemDescription; _ItemDescription)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Description';
                    ToolTip = 'The description of the item.';
                    Editable = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The quantity to sell.';
                }
                field(VisitDate; Rec.VisitDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The local visit date. For a package, it applies to every ticket that has no time of its own from Assign Times.';
                    ShowMandatory = true;
                }
                field(VisitTime; Rec.VisitTime)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The local visit time. For a package, it applies to every ticket that has no time of its own from Assign Times.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The ticket holder''s name. Leave it blank to use the name on the booking.';
                }
                field(NotificationAddress; Rec.NotificationAddress)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The ticket holder''s email address. Leave it blank to use the email address on the booking.';
                }
                field(Language; Rec.Language)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'The ticket holder''s language. Leave it blank to use the language on the booking.';
                    Visible = false;
                }
                field(AmountInclVat; _AmountInclVat)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Amount Incl. VAT';
                    ToolTip = 'The price of the line''s wallets, set when the booking is issued.';
                    Editable = false;
                    AutoFormatType = 1;
                }
                field(PickupState; _PickupState)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'Pick-up';
                    ToolTip = 'Shows whether the line is in a POS sale or has been paid at pick-up.';
                    Editable = false;
                }
                field(ReceiptNo; _ReceiptNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    Caption = 'POS Receipt No.';
                    ToolTip = 'The POS receipt the line was paid on.';
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AssignTimes)
            {
                Caption = 'Assign Times';
                Image = Calendar;
                ToolTip = 'Give the tickets of a package their own visit date and time. Tickets without one use the date and time of the line.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Enabled = _IsPackage;
                Visible = _IsBackOffice;

                trigger OnAction()
                var
                    Order: Record "NPR CMOrder";
                    Visits: Page "NPR CMTourBookingVisits";
                begin
                    CurrPage.SaveRecord();
                    Commit();

                    Order.Get(Rec.OrderId);
                    Visits.LoadLine(Rec);
                    Visits.Editable(_TourBookingMgt.IsEditable(Order));
                    Visits.RunModal();
                    _TourBookingMgt.DefaultLineVisitFromComponents(Rec.OrderId, Rec.LineNo);
                    CurrPage.Update(false);
                end;
            }
            action(Wallets)
            {
                Caption = 'Wallets';
                Image = ItemGroup;
                ToolTip = 'Show the wallets issued for this line.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Visible = _IsBackOffice;

                trigger OnAction()
                var
                    OrderWallet: Record "NPR CMOrderWallet";
                begin
                    OrderWallet.SetFilter(OrderId, '=%1', Rec.OrderId);
                    OrderWallet.SetFilter(LineNo, '=%1', Rec.LineNo);
                    Page.Run(Page::"NPR CMOrderWallets", OrderWallet);
                end;
            }
            action(WalletMailData)
            {
                Caption = 'Wallet Mail Data';
                Image = XMLFile;
                ToolTip = 'Show the data the wallet mail template receives for this line''s recipient.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Scope = Repeater;
                Visible = _IsBackOffice;

                trigger OnAction()
                var
                    Order: Record "NPR CMOrder";
                    Distribution: Codeunit "NPR CMOrderDistribution";
                begin
                    Order.Get(Rec.OrderId);
                    Message('%1', Distribution.GetWalletMailData(Order, Rec));
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        _IsBackOffice := not POSSession.IsInitialized();
    end;

    trigger OnAfterGetRecord()
    begin
        UpdateLineInfo();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        _IsPackage := Rec.IsPackage;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        _TourBookingMgt.DeleteLineComponents(Rec);
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.LineNo := _TourBookingMgt.GetNextLineNo(Rec.OrderId);
        if (_InheritFromLineNo <> 0) then
            _TourBookingMgt.CopyLineComponents(Rec.OrderId, _InheritFromLineNo, Rec.LineNo);
        _InheritFromLineNo := 0;
        exit(true);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(_ItemDescription);
        Clear(_AmountInclVat);
        Clear(_PickupState);
        Clear(_ReceiptNo);
    end;

    local procedure UpdateLineInfo()
    var
        Item: Record Item;
        WalletCount: Integer;
        AmountExclVat: Decimal;
        CurrencyCode: Code[10];
    begin
        _ItemDescription := '';
        Item.SetLoadFields(Description);
        if (Item.Get(Rec.ItemNo)) then
            _ItemDescription := Item.Description;

        _TourBookingMgt.GetLineTotals(Rec, WalletCount, AmountExclVat, _AmountInclVat, CurrencyCode);
        _PickupState := _TourBookingMgt.GetLineState(Rec, _ReceiptNo);
    end;

    var
        _TourBookingMgt: Codeunit "NPR CMTourBookingMgt";
        _ItemDescription: Text[100];
        _AmountInclVat: Decimal;
        _PickupState: Enum "NPR CMOrderLinePickupState";
        _ReceiptNo: Code[20];
        _IsPackage: Boolean;
        _IsBackOffice: Boolean;
        _InheritFromLineNo: Integer;
}
