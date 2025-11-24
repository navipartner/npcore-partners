#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
page 6185067 "NPR Inc Ecom Sales Doc Setup"
{
    PageType = Card;
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    SourceTable = "NPR Inc Ecom Sales Doc Setup";
    Caption = 'Ecommerce Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    Extensible = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
            }
            group(Cusotmer)
            {
                field("Customer Mapping"; Rec."Customer Mapping")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Create Customer field.';
                }
                field("Def. Customer Template Code"; Rec."Def. Customer Template Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Def. Customer Template Code field.';
                }
                field("Def Cust Config Template Code"; Rec."Def Cust Config Template Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Def. Customer Config. Template Code field.';
                }
            }
            group(Documents)
            {
                group(DocumentsGeneral)
                {
                    Caption = 'General';
                    field("Max Doc Process Retry Count"; Rec."Max Doc Process Retry Count")
                    {
                        ToolTip = 'Specifies the value of the Max. Document Process Retry Count field.';
                        ApplicationArea = NPRRetail;
                    }
                    field("Max Capture Retry Count"; Rec."Max Capture Retry Count")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Max Capture Retry Count field.';
                    }
                    field("Max Virtual Item Retry Count"; Rec."Max Virtual Item Retry Count")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Max Capture Retry Count field.';
                    }
                    field("Def. Sales Location Code"; Rec."Def. Sales Location Code")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Def. Sales Location Code field.';
                    }
                    field("Customer Update Mode"; Rec."Customer Update Mode")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Customer Update Mode field.';
                    }
                }
                group(SalesOrders)
                {
                    Caption = 'Sales Orders';

                    field("Release Sale Ord After Prc"; Rec."Release Sale Ord After Prc")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Release Sales Order After Process field.';
                    }
                    field("Proc Sales Order On Receive"; Rec."Proc Sales Order On Receive")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Proc Sales Order On Receive field.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2025-11-17';
                        ObsoleteReason = 'Not used anymore.';
                    }
                    field("Auto Proc Sales Order"; Rec."Auto Proc Sales Order")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Auto Process Sales Order field.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2025-11-17';
                        ObsoleteReason = 'Not used anymore.';
                    }
                }
                group(SalesReturnOrders)
                {
                    Caption = 'Sales Return Orders';
                    field("Auto Proc Sales Ret Order"; Rec."Auto Proc Sales Ret Order")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Auto Process Sales Return Order field.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2025-11-17';
                        ObsoleteReason = 'Not used anymore.';
                    }

                    field("Proc Sales Ret Ord On Receive"; Rec."Proc Sales Ret Ord On Receive")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Process Sales Return Order On Receive field.';
                        Visible = false;
                        ObsoleteState = Pending;
                        ObsoleteTag = '2025-11-17';
                        ObsoleteReason = 'Not used anymore.';
                    }
                    field("Release Sale Ret Ord After Prc"; Rec."Release Sale Ret Ord After Prc")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Release Sales Return Order After Process field.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ConfigureEcomCaptureJobQueue)
            {
                Caption = 'Configure Capture Processing Job Queue';
                ApplicationArea = NPRRetail;
                Image = Add;
                ToolTip = 'Configure Capture Job Queue';

                trigger OnAction()
                var
                    EcomSaleCaptureJQ: Codeunit "NPR EcomSaleCaptureJQ";
                begin
                    EcomSaleCaptureJQ.ScheduleJobQueueWithConfirmation();
                end;
            }
            action(ConfigureEcomVoucherProcessingJobQueue)
            {
                Caption = 'Configure Voucher Processing Job Queue';
                ApplicationArea = NPRRetail;
                Image = Add;
                ToolTip = 'Configure Voucher Processing Job Queue';
                trigger OnAction()
                var
                    EcomCreateVoucherJQ: Codeunit "NPR EcomCreateVoucherJQ";
                begin
                    EcomCreateVoucherJQ.ScheduleJobQueueWithConfirmation();
                end;
            }
            action(ConfigureEcomSalesOrderProcessingJobQueue)
            {
                Caption = 'Configure Sales Order Processing Job Queue';
                ApplicationArea = NPRRetail;
                Image = Add;
                ToolTip = 'Configure Sales Order Processing Job Queue';

                trigger OnAction()
                var
                    EcomSalesOrderProcJQ: Codeunit "NPR EcomSalesOrderProcJQ";
                begin
                    EcomSalesOrderProcJQ.ScheduleJobQueueWithConfirmation();
                end;
            }
            action(ConfigureEcomSalesReturnOrderProcessingJobQueue)
            {
                Caption = 'Configure Sales Return Order Processing Job Queue';
                ApplicationArea = NPRRetail;
                Image = Add;
                ToolTip = 'Configure Sales Return Order Processing Job Queue';

                trigger OnAction()
                var
                    EcomSalesRetOrderProcJQ: Codeunit "NPR EcomSalesRetOrderProcJQ";
                begin
                    EcomSalesRetOrderProcJQ.ScheduleJobQueueWithConfirmation();
                end;
            }
        }
        area(Navigation)
        {
            action(PaymentMethodMapping)
            {
                Caption = 'Payment Method Mapping';
                ApplicationArea = NPRRetail;
                Image = Setup;
                ToolTip = 'Executes the Payment Method Mapping action.';
                trigger OnAction()
                var
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenPaymentMethodMapping();
                end;
            }
            action(ShipmentMethodMapping)
            {
                Caption = 'Shipment Method Mapping';
                ApplicationArea = NPRRetail;
                Image = Setup;
                ToolTip = 'Executes the Shipment Method Mapping action.';
                trigger OnAction()
                var
                    EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
                begin
                    EcomSalesDocUtils.OpenShipmentMethodMapping();
                end;
            }
            action(JobQueueList)
            {
                Caption = 'Job Queue List';
                ApplicationArea = NPRRetail;
                Image = Setup;
                ToolTip = 'View related Job Queus.';
                trigger OnAction()
                var
                    EcomJobManagement: Codeunit "NPR Ecom Job Management";
                begin
                    EcomJobManagement.OpenJobQueueList();
                end;
            }
        }
        area(Promoted)
        {
            group(Home)
            {
                actionref(PaymentMethodMapping_Promoted; PaymentMethodMapping) { }
                actionref(ShipmentMethodMapping_Promoted; ShipmentMethodMapping) { }
                actionref(JobQueueList_Promoted; JobQueueList) { }
                actionref(ConfigureEcomCaptureJobQueue_Promoted; ConfigureEcomCaptureJobQueue) { }
                actionref(ConfigureEcomVoucherProcessingJobQueue_Promoted; ConfigureEcomVoucherProcessingJobQueue) { }
                actionref(ConfigureEcomSalesOrderProcessingJobQueue_Promoted; ConfigureEcomSalesOrderProcessingJobQueue) { }
                actionref(ConfigureEcomSalesReturnOrderProcessingJobQueue_Promoted; ConfigureEcomSalesReturnOrderProcessingJobQueue) { }
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

}
#endIf