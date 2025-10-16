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
                    field("Auto Proc Sales Order"; Rec."Auto Proc Sales Order")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Auto Process Sales Order field.';
                    }
                    field("Proc Sales Order On Receive"; Rec."Proc Sales Order On Receive")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Proc Sales Order On Receive field.';
                    }
                    field("Release Sale Ord After Prc"; Rec."Release Sale Ord After Prc")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Release Sales Order After Process field.';
                    }
                }
                group(SalesReturnOrders)
                {
                    Caption = 'Sales Return Orders';
                    field("Auto Proc Sales Ret Order"; Rec."Auto Proc Sales Ret Order")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Auto Process Sales Return Order field.';
                    }
                    field("Proc Sales Ret Ord On Receive"; Rec."Proc Sales Ret Ord On Receive")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Process Sales Return Order On Receive field.';
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
                    IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                begin
                    IncEcomSalesDocUtils.OpenPaymentMethodMapping();
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
                    IncEcomSalesDocUtils: Codeunit "NPR Inc Ecom Sales Doc Utils";
                begin
                    IncEcomSalesDocUtils.OpenShipmentMethodMapping();
                end;
            }

        }
        area(Promoted)
        {
            group(Home)
            {
                actionref(PaymentMethodMapping_Promoted; PaymentMethodMapping) { }
                actionref(ShipmentMethodMapping_Promoted; ShipmentMethodMapping) { }
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