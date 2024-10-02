page 6014464 "NPR APIV1 - Dimension Values"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityCaption = 'Dimension Value';
    EntitySetCaption = 'Dimension Values';
    EntityName = 'dimensionValue';
    EntitySetName = 'dimensionValues';
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Dimension Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                }
                field(dimensionId; Rec."Dimension Id")
                {
                    Caption = 'Dimension Id', Locked = true;
                }

                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code', Locked = true;
                }

                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name', Locked = true;
                }

                field(dimensionValueType; Rec."Dimension Value Type")
                {
                    Caption = 'Dimension Value Type', Locked = true;
                }

                field(totaling; Rec.Totaling)
                {
                    Caption = 'Totaling', Locked = true;
                }

                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }

                field(consolidationCode; Rec."Consolidation Code")
                {
                    Caption = 'Consolidation Code', Locked = true;
                }

                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation', Locked = true;
                }

                field(globalDimensionNo; Rec."Global Dimension No.")
                {
                    Caption = 'Global Dimension No.', Locked = true;
                }

                field(mapToICDimensionCode; Rec."Map-to IC Dimension Code")
                {
                    Caption = 'Map-to IC Dimension Code', Locked = true;
                }

                field(mapToICDimensionValueCode; Rec."Map-to IC Dimension Value Code")
                {
                    Caption = 'Map-to IC Dimension Value Code', Locked = true;
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
}
