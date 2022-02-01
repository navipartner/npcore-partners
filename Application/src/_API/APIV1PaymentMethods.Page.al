page 6014662 "NPR APIV1 - Payment Methods"
{
    Extensible = False;

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Payment Methods';
    DelayedInsert = true;
    EntityName = 'paymentMethod';
    EntitySetName = 'paymentMethods';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Payment Method";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(balAccountNo; Rec."Bal. Account No.")
                {
                    Caption = 'Bal. Account No.', Locked = true;
                }
                field(balAccountType; Rec."Bal. Account Type")
                {
                    Caption = 'Bal. Account Type', Locked = true;
                }
                field(directDebit; Rec."Direct Debit")
                {
                    Caption = 'Direct Debit', Locked = true;
                }
                field(directDebitPmtTermsCode; Rec."Direct Debit Pmt. Terms Code")
                {
                    Caption = 'Direct Debit Pmt. Terms Code', Locked = true;
                }
                field(pmtExportLineDefinition; Rec."Pmt. Export Line Definition")
                {
                    Caption = 'Pmt. Export Line Definition', Locked = true;
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
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
