﻿report 6014494 "NPR MM Member Evaluation"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    Caption = 'Member Evaluation';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM_MemberEvaluation.rdl';

    dataset
    {
        dataitem(Membership; "NPR MM Membership")
        {
            trigger OnPreDataItem()
            begin
                RecordCount := Membership.Count();
                DialogModBase := 1;
                if (RecordCount > 100) then
                    DialogModBase := Round(RecordCount / 100, 1, '<');
            end;

            trigger OnAfterGetRecord()
            var
                MembershipRole: Record "NPR MM Membership Role";
            begin
                MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                MembershipRole.SetFilter(Blocked, '=%1', false);

                if (MembershipRole.FindSet()) then begin
                    repeat
                        TmpAgrBuffer.Template := Membership."External Membership No.";
                        TmpAgrBuffer."Line No." := MembershipRole."Member Entry No."; // Used to link to dataitem

                        TmpAgrBuffer.Init();
                        TmpAgrBuffer."Code 2" := Membership."Membership Code"; // Used in CollectMetrics() for simplified access
                        TmpAgrBuffer."Code 3" := Membership."Customer No.";    // Used in CollectMetrics() for simplified access
                        TmpAgrBuffer."Indent 5" := Membership."Entry No.";     // Used to link to dataitem 
                        if (WasActiveInTimeFrame(Membership."Entry No.")) then
                            TmpAgrBuffer.Insert();

                        if (GuiAllowed()) then
                            if (Index mod DialogModBase = 0) then
                                Window.Update(2, Round(Index / RecordCount * 10000, 1));

                        Index += 1;

                    until (MembershipRole.Next() = 0);
                end;
            end;

            trigger OnPostDataItem()
            begin
                TmpAgrBuffer.Reset();
                if (GuiAllowed()) then
                    Window.Update(1, SELECTING_METRICS);

                RecordCount := TmpAgrBuffer.Count();
                DialogModBase := 1;
                Index := 0;
                if (RecordCount > 100) then
                    DialogModBase := Round(RecordCount / 100, 1, '<');

                if (TmpAgrBuffer.FindSet()) then begin
                    repeat

                        if (CollectMetrics()) then
                            TmpAgrBuffer.Modify();

                        if (GuiAllowed()) then
                            if (Index mod DialogModBase = 0) then
                                Window.Update(2, Round(Index / RecordCount * 10000, 1));

                        Index += 1;

                    until (TmpAgrBuffer.Next() = 0);
                end;
            end;
        }
        dataitem(TmpAgrBuffer; "NPR TEMP Buffer")
        {
            UseTemporary = true;
            DataItemTableView = sorting(Template, "Line No.");

            column(Indent; Indent)
            {
            }
            column(Indent_2; "Indent 2")
            {
            }
            column(Indent_3; "Indent 3")
            {
            }

            column(Indent_4; "Indent 4")
            {
            }
            column(Color; Color)
            {
            }
            column(Color_2; "Color 2")
            {
            }
            column(Decimal_1; "Decimal 1")
            {
            }
            column(Decimal_2; "Decimal 2")
            {
            }
            column(Decimal_3; "Decimal 3")
            {
            }

            dataitem(ReportedMembership; "NPR MM Membership")
            {
                DataItemLink = "Entry No." = field("Indent 5");
                DataItemTableView = sorting("Entry No.");

                column(External_Membership_No_;
                "External Membership No.")
                {
                    IncludeCaption = true;
                }
                column(Issued_Date; "Issued Date")
                {
                    IncludeCaption = true;
                }

                column(Membership_Code; "Membership Code")
                {
                    IncludeCaption = true;
                }

                column(Customer_No_; "Customer No.")
                {
                    IncludeCaption = true;
                }

                dataitem(ReportedMember; "NPR MM Member")
                {
                    DataItemLinkReference = TmpAgrBuffer;
                    DataItemLink = "Entry No." = field("Line No.");
                    DataItemTableView = sorting("Entry No.");

                    column(External_Member_No_; "External Member No.")
                    {
                        IncludeCaption = true;
                    }
                    column(First_Name; "First Name")
                    {
                        IncludeCaption = true;
                    }
                    column(Last_Name; "Last Name")
                    {
                        IncludeCaption = true;
                    }
                    column(Display_Name; "Display Name")
                    {
                        IncludeCaption = true;
                    }
                    column(E_Mail_Address; "E-Mail Address")
                    {
                        IncludeCaption = true;
                    }
                    column(Birthday; Birthday)
                    {
                        IncludeCaption = true;
                    }
                    column(Gender; Gender)
                    {
                        IncludeCaption = true;
                    }

                    column(Address; Address)
                    {
                        IncludeCaption = true;
                    }

                    column(Post_Code_Code; "Post Code Code")
                    {
                        IncludeCaption = true;
                    }

                    column(City; City)
                    {
                        IncludeCaption = true;
                    }

                    column(Country_Code; "Country Code")
                    {
                        IncludeCaption = true;
                    }

                    column(Country; Country)
                    {
                        IncludeCaption = true;
                    }
                }
            }

        }

    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                    Caption = 'General';

                    field(StartDate; FromDate)
                    {
                        Caption = 'From Date';

                        ToolTip = 'Select memberships that was active after this date.';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field(EndDate; ToDate)
                    {
                        Caption = 'Until Date';

                        ToolTip = 'Select memberships that was active before this date.';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                    field(CompleteHistory; FullHistory)
                    {
                        Caption = 'Include Full History';

                        ToolTip = 'Ignore dates when calculating metrics for member activity.';
                        ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                    }
                }
            }
        }
    }


    labels
    {
        Indent_Label = 'Issued Guest Ticket Count';
        Indent_2_Label = 'Issued Member Ticket Count';
        Indent_3_Label = 'Arrival Log Success Count';
        Indent_4_Label = 'Issued Ticket Count';
        Color_Label = 'POS Sales Count';
        Color_2_Label = 'Invoice Count';
        Decimal_1_Label = 'Total POS Amount Incl. Discount And Tax';
        Decimal_2_Label = 'Total POS Discount';
        Decimal_3_Label = 'Total Invoice Amount';


    }

    var
        FromDate: Date;
        ToDate: Date;
        Window: Dialog;
        RecordCount: Integer;
        Index: Integer;
        DialogModBase: Integer;
        FullHistory: Boolean;

        DIALOG_TXT: Label '#1############################ @2@@@@@@@@@@@@@@@@@@', Locked = true;
        SELECTING_MEMBERSHIPS: Label 'Selecting memberships';
        SELECTING_METRICS: Label 'Selecting metrics';

    trigger OnInitReport()
    begin
        FromDate := 0D;
        ToDate := Today();
    end;

    trigger OnPreReport()
    begin
        if (GuiAllowed()) then begin
            Window.Open(DIALOG_TXT);
            Window.Update(1, SELECTING_MEMBERSHIPS);
        end;
    end;

    trigger OnPostReport()
    begin
        if (GuiAllowed()) then
            Window.Close();
    end;

    local procedure WasActiveInTimeFrame(MembershipEntryNo: Integer): Boolean
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        // Only From Date is within requested time period
        MembershipEntry.Reset();
        MembershipEntry.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.SetFilter("Valid From Date", '..%1', ToDate);
        MembershipEntry.SetFilter("Valid Until Date", '%1..', FromDate);
        exit(not MembershipEntry.IsEmpty());
    end;

    local procedure CollectMetrics(): Boolean
    var
        Member: Record "NPR MM Member";
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
        IssuedTicket: Record "NPR TM Ticket";
        MembershipSetup: Record "NPR MM Membership Setup";
        ItemReference: Record "Item Reference";
        POSEntry: Record "NPR POS Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin

        if (not Member.Get(TmpAgrBuffer."Line No.")) then
            exit(false);

        // Card Scan
        MemberArrivalLogEntry.SetCurrentKey("External Membership No.", "External Member No.", "Event Type", "Response Type", "Local Date");
        MemberArrivalLogEntry.SetFilter("External Membership No.", '=%1', TmpAgrBuffer.Template);
        MemberArrivalLogEntry.SetFilter("External Member No.", '=%1', Member."External Member No.");
        MemberArrivalLogEntry.SetFilter("Event Type", '=%1', MemberArrivalLogEntry."Event Type"::ARRIVAL);
        MemberArrivalLogEntry.SetFilter("Response Type", '=%1', MemberArrivalLogEntry."Response Type"::SUCCESS);

        if (not FullHistory) then
            MemberArrivalLogEntry.SetFilter("Local Date", '%1..%2', FromDate, ToDate);
        TmpAgrBuffer."Indent 3" := MemberArrivalLogEntry.Count();

        // Membership ticket count
        MembershipSetup.Get(CopyStr(TmpAgrBuffer."Code 2", 1, MaxStrLen(MembershipSetup.Code)));
        if (MembershipSetup."Ticket Item Barcode" <> '') then begin
            ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '=%1', MembershipSetup."Ticket Item Barcode");
            if (not ItemReference.FindFirst()) then
                ItemReference.Init();

            IssuedTicket.SetFilter("External Member Card No.", '=%1', Member."External Member No.");
            IssuedTicket.SetFilter(Blocked, '=%1', false);
            if (not FullHistory) then
                IssuedTicket.SetFilter("Document Date", '%1..%2', FromDate, ToDate);
            TmpAgrBuffer."Indent 4" := IssuedTicket.Count();

            if (TmpAgrBuffer."Indent 4" > 0) then begin
                IssuedTicket.FindSet();
                repeat
                    if (IssuedTicket."Item No." = ItemReference."Item No.") and (IssuedTicket."Variant Code" = ItemReference."Variant Code") then begin
                        TmpAgrBuffer."Indent 2" += 1; // Member ticket
                    end else begin
                        TmpAgrBuffer.Indent += 1; // Guest ticket
                    end;
                until (IssuedTicket.Next() = 0);
            end;
        end;

        // Revenue
        if (TmpAgrBuffer."Code 3" <> '') then begin
            POSEntry.SetCurrentKey("Customer No.", "Sales Document Type", "Document Date");
            POSEntry.SetFilter("Customer No.", '=%1', TmpAgrBuffer."Code 3");
            if (not FullHistory) then
                POSEntry.SetFilter("Document Date", '%1..%2', FromDate, ToDate);
            POSEntry.SetFilter("Sales Document Type", '=%1', POSEntry."Sales Document Type"::Quote);
            TmpAgrBuffer.Color := POSEntry.Count(); // POS Sales Count
            if POSEntry.FindSet(false, false) then
                repeat
                    TmpAgrBuffer."Decimal 1" += POSEntry."Amount Incl. Tax"; // Total POS Amount Including Discount and Tax
                    TmpAgrBuffer."Decimal 2" += POSEntry."Discount Amount"; // Total POS Discount
                until POSEntry.Next() = 0;

            SalesInvoiceHeader.SetFilter("Bill-to Customer No.", '=%1', TmpAgrBuffer."Code 3");
            if (not FullHistory) then
                SalesInvoiceHeader.SetFilter("Document Date", '%1..%2', FromDate, ToDate);
            TmpAgrBuffer."Color 2" := SalesInvoiceHeader.Count();
            if (SalesInvoiceHeader.FindSet()) then begin
                repeat
                    SalesInvoiceHeader.CalcFields("Amount Including VAT");
                    TmpAgrBuffer."Decimal 3" += SalesInvoiceHeader."Amount Including VAT";
                until (SalesInvoiceHeader.Next() = 0);
            end;
        end;

        exit(true);

    end;
}
