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
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(balance; Rec."Balance (LCY)")
                {
                    Caption = 'Balance';
                    Editable = false;
                }
                field(totalSalesExcludingTax; Rec."Sales (LCY)")
                {
                    Caption = 'Total Sales Excluding Tax';
                    Editable = false;
                }
                field(overdueAmount; Rec."Balance Due (LCY)")
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
        Rec.SetRange(Rec."Date Filter", 0D, WorkDate() - 1);
        Rec.CalcFields(Rec."Balance Due (LCY)", "Sales (LCY)", "Balance (LCY)");
    end;

}