page 6151476 "NPR TM RevenueRecognition"
{
    Extensible = false;

    Caption = 'Ticket Revenue Deferral Overview';
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM DeferRevenueRequest";
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';
    InsertAllowed = false;
    DeleteAllowed = false;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(TicketAccessEntryNo; Rec.TicketAccessEntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Access Entry No. field.';
                    Editable = false;
                }
                field(TicketNo; Rec.TicketNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field.';
                    Editable = false;
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field.';
                    Editable = false;
                }
                field(VariantCode; Rec.VariantCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    Editable = false;
                }
                field(TicketValidUntil; Rec.TicketValidUntil)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Valid Until field.';
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field.';
                    Editable = false;
                }
                field(SalesDate; Rec.SalesDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Sales Date field.';
                    Editable = false;
                }
                field(RealizationDate; Rec.AchievedDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Realization Date field.';
                }
                field(AmountToDefer; Rec.AmountToDefer)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Amount To Defer field.';
                    DecimalPlaces = 2 : 5;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Status field.';

                    trigger OnValidate()
                    begin
                        if (((xRec.Status = xRec.Status::UNRESOLVED)) and (Rec.Status = Rec.Status::REGISTERED)) then
                            Rec.AttemptedRegisterCount := 0;
                    end;
                }
                field(PaymentOption; Rec.PaymentOption)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Payment Option field.';
                    Editable = false;
                }
                field(SourceType; Rec.SourceType)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Source Type field.';
                    Editable = false;
                }
                field(SourceDocumentNo; Rec.SourceDocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Source Document No. field.';
                    Editable = false;
                }
                field(SourceDocumentLineNo; Rec.SourceDocumentLineNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Source Document Line No. field.';
                    Editable = false;
                }
                field(SourcePostingDate; Rec.SourcePostingDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Source Posting Date field.';
                    Editable = false;
                }
                field(DeferralDocumentDate; Rec.DeferralDocumentDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Document Date field.';
                    Editable = false;
                }
                field(DeferralDocumentNo; Rec.DeferralDocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Deferral Document No field.';
                    Editable = false;
                }
                field(DeferralPostingDate; Rec.DeferralPostingDate)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Posting Date field.';
                    Editable = false;
                }
                field(DimensionSetID; Rec.DimensionSetID)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                    Editable = false;
                }
                field(GlobalDimension1Code; Rec.GlobalDimension1Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field.';
                    Editable = false;
                }
                field(GlobalDimension2Code; Rec.GlobalDimension2Code)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field.';
                    Editable = false;
                }
                field(GenBusPostingGroup; Rec.GenBusPostingGroup)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field.';
                    Editable = false;
                }
                field(GenProdPostingGroup; Rec.GenProdPostingGroup)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Gen. Prod. Posting Group field.';
                    Editable = false;
                }
                field(ReservationRequestEntryNo; Rec.ReservationRequestEntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Reservation Request Entry No. field.';
                    Editable = false;
                }
                field(TokenID; Rec.TokenID)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Session Token ID field.';
                    Editable = false;
                }
                field(ValueEntryNo; Rec.ValueEntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Value Entry No. field.';
                    Editable = false;
                }
                field(AttemptedRegisterCount; Rec.AttemptedRegisterCount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Attempted Register Count field.';
                }
                field(DeferRevenueProfileCode; Rec.DeferRevenueProfileCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Defer Revenue Profile Code field.';
                    Editable = false;
                }
                field(OriginalSalesAccount; Rec.OriginalSalesAccount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Interim Sales Account field.';
                    Editable = false;
                }
                field(AchievedRevenueAccount; Rec.AchievedRevenueAccount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Achieved Revenue Recognition field.';
                    Editable = false;
                }
                field(InterimAdjustmentAccount; Rec.InterimAdjustmentAccount)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Interim Adjustment Account field.';
                    Editable = false;
                    Visible = false;
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(DeferRevenueOne)
            {
                Caption = 'Defer Revenue';
                ToolTip = 'This action will process the selected record.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    DeferRevenue: Codeunit "NPR TM RevenueDeferral";
                begin
                    DeferRevenue.ProcessOne(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(DeferRevenueBatch)
            {
                Caption = 'Defer Revenue (Batch)';
                ToolTip = 'This action will process all records.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Repeater;

                trigger OnAction()
                var
                    DeferRevenue: Codeunit "NPR TM RevenueDeferral";
                begin
                    DeferRevenue.ProcessBatch();
                    CurrPage.Update(false);
                end;
            }

            action(DeleteRegistered)
            {
                Caption = 'Delete Registered';
                ToolTip = 'This action will delete deferral request in status Registered.';
                ApplicationArea = NPRTicketAdvanced;
                Image = Delete;

                trigger OnAction()
                var
                    DeferRevenue: Record "NPR TM DeferRevenueRequest";
                    ConfirmMessage: Label 'Are you sure you want to delete all deferral requests with status Registered?';
                begin
                    if (not Confirm(ConfirmMessage, false)) then
                        exit;

                    DeferRevenue.SetCurrentKey("Status");
                    DeferRevenue.SetFilter("Status", '=%1', DeferRevenue.Status::REGISTERED);
                    DeferRevenue.DeleteAll();
                end;
            }
            action(DeleteUnresolved)
            {
                Caption = 'Delete Unresolved';
                ToolTip = 'This action will delete deferral request in status Unresolved.';
                ApplicationArea = NPRTicketAdvanced;
                Image = Delete;

                trigger OnAction()
                var
                    DeferRevenue: Record "NPR TM DeferRevenueRequest";
                    ConfirmMessage: Label 'Are you sure you want to delete all deferral requests with status Unresolved?';
                begin
                    if (not Confirm(ConfirmMessage, false)) then
                        exit;

                    DeferRevenue.SetCurrentKey("Status");
                    DeferRevenue.SetFilter("Status", '=%1', DeferRevenue.Status::UNRESOLVED);
                    DeferRevenue.DeleteAll();
                end;
            }
        }
        area(Navigation)
        {
            action(TicketAllocation)
            {
                Caption = 'Ticket Allocation';
                ToolTip = 'Opens a list to view the ticket allocation on the source document.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = ViewDocumentLine;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Repeater;

                RunObject = page "NPR TM DeferRevenueReqDetail";
                RunPageLink = TokenID = Field(TokenID);
            }
            action(DeferralEntries)
            {
                Caption = 'Find Posted Deferral';
                ToolTip = 'Executes the Find entries action ';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Scope = Repeater;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec.DeferralPostingDate, Rec.DeferralDocumentNo);
                    Navigate.Run();
                end;
            }

            action(SourceEntries)
            {
                Caption = 'Find Source Entries';
                ToolTip = 'Executes the Find entries action ';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                Scope = Repeater;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec.SourcePostingDate, rec.SourceDocumentNo);
                    Navigate.Run();
                end;
            }
            action(DeferralProfile)
            {
                Caption = 'Deferral Profile';
                ToolTip = 'Opens a list to view the deferral profiles.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Image = ViewDocumentLine;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Scope = Repeater;

                RunObject = page "NPR TM DeferRevenueProfileList";
                RunPageLink = DeferRevenueProfileCode = Field(DeferRevenueProfileCode);
            }
        }
    }
}