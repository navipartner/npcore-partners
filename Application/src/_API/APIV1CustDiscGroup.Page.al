page 6014649 "NPR APIV1 - Cust Disc. Group"
{
    Extensible = False;

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Customer Discount Group';
    DelayedInsert = true;
    EntityName = 'customerDiscountGroup';
    EntitySetName = 'customerDiscountGroups';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Customer Discount Group";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'SystemId', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified DateTime', Locked = true;
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
