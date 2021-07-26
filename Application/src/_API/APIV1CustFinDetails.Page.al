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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(balance; "Balance (LCY)")
                {
                    Caption = 'Balance';
                    Editable = false;
                }
                field(totalSalesExcludingTax; "Sales (LCY)")
                {
                    Caption = 'Total Sales Excluding Tax';
                    Editable = false;
                }
                field(overdueAmount; "Balance Due (LCY)")
                {
                    Caption = 'Overdue Amount';
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
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnAfterGetRecord()
    begin
        SetRange("Date Filter", 0D, WorkDate() - 1);
        CalcFields("Balance Due (LCY)", "Sales (LCY)", "Balance (LCY)");
    end;

}