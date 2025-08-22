page 6151250 "NPR Retail Enter. Act - Ticket"
{
    Extensible = False;
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Issued Tickets"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Issued Tickets"))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of issued tickets.';
                    Caption = 'Issued';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket List");
                    end;
                }
                field("Ticket Requests"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Ticket Requests"))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of ticket requests.';
                    Caption = 'Requests';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Request");
                    end;
                }
                field("Ticket Types"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Ticket Types"))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of ticket types.';
                    Caption = 'Types';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Type");
                    end;
                }
                field(TicketItems; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(TicketItems))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of ticket items.';
                    Caption = 'Items';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Item List");
                    end;
                }
                field("Ticket Admission BOM"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Ticket Admission BOM"))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Ticket BOM field.';
                    Caption = 'Ticket BOM';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket BOM");
                    end;
                }
                field("Ticket Schedules"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Ticket Schedules"))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Ticket Schedules.';
                    Caption = 'Schedules';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Schedules");
                    end;
                }
                field("Ticket Admissions"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Ticket Admissions"))))
                {
                    ApplicationArea = NPRRetail;
                    DrillDownPageID = "NPR TM Ticket Admissions";
                    ToolTip = 'Specifies the list of Ticket Admissions.';
                    Caption = 'Admissions';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR TM Ticket Admissions");
                    end;
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field(Control6; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Members))))
                {
                    ApplicationArea = NPRRetail;
                    ShowCaption = false;
                    ToolTip = 'Specifies the list of Members associated with different Memberships.';
                    Caption = 'Members';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR MM Members");
                    end;
                }
                field(Memberships; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Memberships))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Memberships.';
                    Caption = 'Memberships';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR MM Memberships");
                    end;
                }
                field(Membercards; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Membercards))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Member Cards.';
                    Caption = 'Member Cards';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR MM Member Card List");
                    end;
                }
            }

            cuegroup(Master)
            {
                Caption = 'Master';
                field(Items; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Items))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Items.';
                    Caption = 'Items';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Item List");
                    end;
                }

                field(Contacts; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Contacts))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Contacts.';
                    Caption = 'Contacts';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Contact List");
                    end;
                }
                field(Customers; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Customers))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Customers.';
                    Caption = 'Customers';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Customer List");
                    end;
                }
            }

            cuegroup(Coupons)
            {
                Caption = 'Coupons';
                field(CouponItems; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Coupons))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Coupons.';
                    Caption = 'Coupons';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR NpDc Coupons");
                    end;
                }
            }

            cuegroup(Vouchers)
            {
                Caption = 'Vouchers';
                field(VoucherItems; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(Vouchers))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Vouchers.';
                    Caption = 'Vouchers';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR NpRv Vouchers");
                    end;
                }
            }

            cuegroup(AttractionWallets)
            {
                Caption = 'Attraction Wallets';
                field(IssuedAttractionWallets; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(IssuedAttractionWalletsCount))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of issued Attraction Wallets.';
                    Caption = 'Issued';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR AttractionWallets");
                    end;
                }
                field(AttractionPackageTemplates; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo(AttractionPackageTemplateCount))))
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the list of Attraction Package Templates.';
                    Caption = 'Templates';
                    AutoFormatType = 11;
                    AutoFormatExpression = '<Precision,0:0><Standard Format,0>';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"NPR WalletTemplate");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Entertai. Cue Backgrd Task");
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        BackgrndTaskMgt.CopyTaskResults(Results, BackgroundTaskResults);
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if (TaskId = BackgroundTaskId) then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Decimal
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit(0);
        if not Evaluate(Result, BackgroundTaskResults.Get(FieldNo), 9) then
            Result := 0;
    end;

    var
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;
}