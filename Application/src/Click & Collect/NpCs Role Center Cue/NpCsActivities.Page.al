page 6184590 "NPR NpCs Activities"
{
    Extensible = false;
    Caption = 'Collect Order - Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR NpCs Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(CCOrderActivities)
            {
                Caption = '';
                ShowCaption = false;

#if not BC17
                field("Spfy CC Orders - Unprocessed"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Spfy CC Orders - Unprocessed"))))
                {
                    Caption = 'Unprocessed Shopify CC Orders';
                    ToolTip = 'Specifies the number of unprocessed Shopify collect in store orders.';
                    ApplicationArea = NPRShopify;

                    trigger OnDrillDown()
                    var
                        SpfyCCOrder: Record "NPR Spfy C&C Order";
                    begin
                        SpfyCCOrder.SetRange(Status, SpfyCCOrder.Status::Error);
                        Page.Run(0, SpfyCCOrder);
                    end;
                }
#endif
                field("CiS Orders - Pending"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("CiS Orders - Pending"))))
                {
                    Caption = 'Pending Collect Orders';
                    ToolTip = 'Specifies the number of pending collect in store orders.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownCCOrders(0, 3);
                    end;
                }
                field("CiS Orders - Confirmed"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("CiS Orders - Confirmed"))))
                {
                    Caption = 'Confirmed Collect Orders';
                    ToolTip = 'Specifies the number of confirmed collect in store orders.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownCCOrders(1, 0);
                    end;
                }
                field("CiS Orders - Finished"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("CiS Orders - Finished"))))
                {
                    Caption = 'Finished Collect Orders';
                    ToolTip = 'Specifies the number of finished collect in store orders.';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownCCOrders(1, 1);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CuesAndKpis.OpenCustomizePageForCurrentUser(CueRecordRef.Number);
                end;
            }
        }
    }

    trigger OnOpenPage();
    var
        ConfPersonalizationMgt: Codeunit "Conf./Personalization Mgt.";
        RoleCenterNotificationMgt: Codeunit "Role Center Notification Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        RoleCenterNotificationMgt.ShowNotifications();
        ConfPersonalizationMgt.RaiseOnOpenRoleCenterEvent();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR NpCs Cue Backgrd Task");
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

    local procedure GetFieldValueFromBackgroundTaskResultSet(FieldNo: Text) Result: Integer
    begin
        if not BackgroundTaskResults.ContainsKey(FieldNo) then
            exit(0);
        if not Evaluate(Result, BackgroundTaskResults.Get(FieldNo), 9) then
            Result := 0;
    end;

    local procedure DrillDownCCOrders(ProcessingStatus: Option Pending,Confirmed,Rejected,Expired; DeliveryStatus: Option Ready,Delivered,Expired,NoFilters)
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        Clear(NpCsDocument);
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetFilter("Document Type", '%1|%2', NpCsDocument."Document Type"::Order, NpCsDocument."Document Type"::"Posted Invoice");
        case ProcessingStatus of
            ProcessingStatus::Pending:
                NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Pending);
            ProcessingStatus::Confirmed:
                NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Confirmed);
            ProcessingStatus::Rejected:
                NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Rejected);
            ProcessingStatus::Expired:
                NpCsDocument.SetRange("Processing Status", NpCsDocument."Processing Status"::Expired);
        end;
        case DeliveryStatus of
            DeliveryStatus::Ready:
                NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Ready);
            DeliveryStatus::Delivered:
                NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Delivered);
            DeliveryStatus::Expired:
                NpCsDocument.SetRange("Delivery Status", NpCsDocument."Delivery Status"::Expired);
        end;
        Page.Run(Page::"NPR NpCs Coll. Store Orders", NpCsDocument);
    end;

    var
        CuesAndKpis: Codeunit "Cues And KPIs";
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;
}