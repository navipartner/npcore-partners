page 6059984 "NPR Web Manager Activ."
{
    Extensible = False;
    Caption = 'Web Order Activities';
    PageType = CardPart;
    SourceTable = "NPR Retail Order Cue";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            cuegroup("Open Orders")
            {
                Caption = 'Open Orders';
                field("Open Web Sales Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Open Web Sales Orders"))))
                {
                    Caption = 'Open Web Sales Orders';
                    ToolTip = 'Specifies the value of the Open Web Sales Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownRetailOrderCue(Rec.FieldNo("Open Web Sales Orders"));
                    end;
                }
                field("Open Credit Memos"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Open Credit Memos"))))
                {
                    Caption = 'Open Credit Memos';
                    ToolTip = 'Specifies the value of the Open Credit Memos field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Sales Credit Memos");
                    end;
                }
                field("Open Purchase Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Open Purchase Orders"))))
                {
                    Caption = 'Open Purchase Orders';
                    ToolTip = 'Specifies the value of the Open Purchase Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Purchase Order List");
                    end;
                }
            }
            cuegroup("Processed Orders")
            {
                Caption = 'Processed Orders';
                field("Posted Web Sales Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Posted Web Sales Orders"))))
                {
                    Caption = 'Posted Web Sales Orders';
                    ToolTip = 'Specifies the value of the Posted Web Sales Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        DrillDownRetailOrderCue(Rec.FieldNo("Posted Web Sales Orders"));
                    end;
                }
                field("Posted Credit Memos"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Posted Credit Memos"))))
                {
                    Caption = 'Posted Credit Memos';
                    ToolTip = 'Specifies the value of the Posted Credit Memos field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Posted Sales Credit Memos");
                    end;
                }
                field("Posted Purchase Orders"; GetFieldValueFromBackgroundTaskResultSet(Format(Rec.FieldNo("Posted Purchase Orders"))))
                {
                    Caption = 'Posted Purchase Orders';
                    ToolTip = 'Specifies the value of the Posted Purchase Orders field';
                    ApplicationArea = NPRRetail;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Posted Purchase Invoices");
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("New Credit Memo")
            {
                Caption = 'New Credit Memo';
                RunObject = Page "Sales Credit Memo";
                RunPageMode = Create;

                ToolTip = 'Executes the New Credit Memo action';
                Image = New;
                ApplicationArea = NPRRetail;
            }
            action("New Purchase Order")
            {
                Caption = 'New Purchase Order';
                RunObject = Page "Purchase Order";

                ToolTip = 'Executes the New Purchase Order action';
                Image = New;
                ApplicationArea = NPRRetail;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.EnqueueBackgroundTask(BackgroundTaskId, Codeunit::"NPR Order Cue Backgrd Task");
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

    local procedure DrillDownRetailOrderCue(DrillDownFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        case DrillDownFieldNo of
            Rec.FieldNo("Open Web Sales Orders"):
                begin
                    SalesHeader.SetFilter("NPR External Order No.", '<> %1', '');
                    SalesHeader.SetFilter("Document Type", '= %1', SalesHeader."Document Type"::Order);
                    Page.Run(Page::"Sales Order List", SalesHeader);
                end;
            Rec.FieldNo("Posted Web Sales Orders"):
                begin
                    SalesHeader.SetFilter("NPR External Order No.", '<> %1', '');
                    Page.Run(Page::"Sales Invoice List", SalesHeader);
                end;
        end;
        CurrPage.Update(false);
    end;

    var
        BackgroundTaskResults: Dictionary of [Text, Text];
        BackgroundTaskId: Integer;
}
