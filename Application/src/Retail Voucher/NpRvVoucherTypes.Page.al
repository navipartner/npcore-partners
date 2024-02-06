page 6151013 "NPR NpRv Voucher Types"
{
    Extensible = False;
    Caption = 'Retail Voucher Types';
    ContextSensitiveHelpPage = 'docs/retail/vouchers/explanation/voucher_types/';
    CardPageID = "NPR NpRv Voucher Type Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Voucher Type";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code value associated with the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the description of the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the code of the No. Series field for the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Period"; Rec."Valid Period")
                {

                    ToolTip = 'Specifies the valid period for the Voucher Type';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(FactBoxes)
        {
            part(VoucherTypeFactbox; "NPR NpRv Voucher Type Factbox")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Background Calculated Fields';
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Vouchers)
            {
                Caption = 'Vouchers';
                Image = Voucher;
                RunObject = Page "NPR NpRv Vouchers";
                RunPageLink = "Voucher Type" = FIELD(Code);
                ShortCutKey = 'Ctrl+F7';

                ToolTip = 'Opens the Vouchers page for the selected Voucher Type';
                ApplicationArea = NPRRetail;
            }
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Voucher Type" = FIELD(Code);

                ToolTip = 'Opens the Partner Relations page for the selected Voucher Type';
                ApplicationArea = NPRRetail;
            }
        }
    }
    var
        BackgroundTaskId: Integer;

    trigger OnAfterGetCurrRecord()
    var
        BackgroundTaskParameters: Dictionary of [Text, Text];
        IsHandled: Boolean;
    begin
        OnBeforeEnqueuePageBackgroundTask(IsHandled);
        if not IsHandled then begin
            CreateBackgroundTaskParameters(BackgroundTaskParameters);
            CurrPage.VoucherTypeFactbox.Page.InitData(Rec, BackgroundTaskParameters);
            EnqueueFlowFieldsCalculationBackgroundTask(BackgroundTaskParameters);
        end;
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        IsHandled: Boolean;
    begin
        OnBeforeOnPageBackgroundTaskCompleted(IsHandled);
        if not IsHandled then
            CurrPage.VoucherTypeFactbox.Page.FinishFillData(Results);
    end;

    local procedure CreateBackgroundTaskParameters(var BackgroundTaskParameters: Dictionary of [Text, Text])
    var
    begin
        clear(BackgroundTaskParameters);
        BackgroundTaskParameters.Add('VoucherTypeCode', Rec.Code);
        BackgroundTaskParameters.Add(Format(Rec.FieldNo("Voucher Qty. (Open)")), '');
        BackgroundTaskParameters.Add(Format(Rec.FieldNo("Voucher Qty. (Closed)")), '');
        BackgroundTaskParameters.Add(Format(Rec.FieldNo("Arch. Voucher Qty.")), '');
    end;

    local procedure EnqueueFlowFieldsCalculationBackgroundTask(BackgroundTaskParameters: Dictionary of [Text, Text])

    begin
        if (BackgroundTaskId <> 0) then
            CurrPage.CancelBackgroundTask(BackgroundTaskId);

        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR NpRv Ret. Vouch. Type Task", BackgroundTaskParameters);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEnqueuePageBackgroundTask(var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnPageBackgroundTaskCompleted(var IsHandled: Boolean)
    begin
    end;
}