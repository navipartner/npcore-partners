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
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF
            }
        }
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

}
