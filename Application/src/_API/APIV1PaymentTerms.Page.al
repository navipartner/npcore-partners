page 6014661 "NPR APIV1 - Payment Terms"
{
    Extensible = False;

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Payment Terms';
    DelayedInsert = true;
    EntityName = 'paymentTerm';
    EntitySetName = 'paymentTerms';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Payment Terms";

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
                field(discount; Rec."Discount %")
                {
                    Caption = 'Discount %', Locked = true;
                }
                field(calcPmtDiscOnCrMemos; Rec."Calc. Pmt. Disc. on Cr. Memos")
                {
                    Caption = 'Calc. Pmt. Disc. on Cr. Memos', Locked = true;
                }
                field(discountDateCalculation; Rec."Discount Date Calculation")
                {
                    Caption = 'Discount Date Calculation', Locked = true;
                }
                field(dueDateCalculation; Rec."Due Date Calculation")
                {
                    Caption = 'Due Date Calculation', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = 'NPR23.0';
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
