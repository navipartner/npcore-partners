page 6014508 "NPR APIV1 - Cust Fin Details"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DeleteAllowed = false;
    DelayedInsert = true;
    Editable = false;
    EntityName = 'customerFinancialDetail';
    EntitySetName = 'customerFinancialDetails';
    EntityCaption = 'Customer Financial Detail';
    EntitySetCaption = 'Customer Financial Details';
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Customer;
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                    Editable = false;
                }
                field(balance; Rec."Balance (LCY)")
                {
                    Caption = 'Balance', Locked = true;
                    Editable = false;
                }
                field(totalSalesExcludingTax; Rec."Sales (LCY)")
                {
                    Caption = 'Total Sales Excluding Tax', Locked = true;
                    Editable = false;
                }
                field(overdueAmount; Rec."Balance Due (LCY)")
                {
                    Caption = 'Overdue Amount', Locked = true;
                    Editable = false;
                }
            }
        }

    }

    actions
    {
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.SetRange(Rec."Date Filter", 0D, WorkDate() - 1);
        Rec.CalcFields(Rec."Balance Due (LCY)", "Sales (LCY)", "Balance (LCY)");
    end;

}