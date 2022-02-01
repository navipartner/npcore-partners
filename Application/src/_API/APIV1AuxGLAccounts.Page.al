page 6059847 "NPR APIV1 - Aux. G/L Accounts"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'AuxGLAccounts';
    DelayedInsert = true;
    EntityName = 'auxGLAccount';
    EntitySetName = 'auxGLAccounts';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Aux. G/L Account";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemID)
                {
                    Caption = 'Id', Locked = true;
                }
                field(no; Rec."No.")
                {
                    Caption = 'No.', Locked = true;
                }
                field(retailPayment; Rec."Retail Payment")
                {
                    Caption = 'Retail Payment', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
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
