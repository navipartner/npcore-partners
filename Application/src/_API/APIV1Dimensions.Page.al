page 6014469 "NPR APIV1 - Dimensions"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DeleteAllowed = false;
    DelayedInsert = true;
    EntityCaption = 'Dimension';
    EntitySetCaption = 'Dimensions';
    Extensible = false;
    Editable = false;
    EntityName = 'dimension';
    EntitySetName = 'dimensions';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Dimension;

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
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name', Locked = true;
                }

                field(codeCaption; Rec."Code Caption")
                {
                    Caption = 'Code Caption', Locked = true;
                }

                field(filterCaption; Rec."Filter Caption")
                {
                    Caption = 'Filter Caption', Locked = true;
                }

                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }

                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked', Locked = true;
                }

                field(consolidationCode; Rec."Consolidation Code")
                {
                    Caption = 'Consolidation Code', Locked = true;
                }

                field(mapToICDimensionCode; Rec."Map-to IC Dimension Code")
                {
                    Caption = 'Map-to IC Dimension Code', Locked = true;
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
                part(dimensionValues; "NPR APIV1 - Dimension Values")
                {
                    Caption = 'Dimension Values', Locked = true;
                    EntityName = 'dimensionValue';
                    EntitySetName = 'dimensionValues';
                    SubPageLink = "Dimension Id" = Field(SystemId);
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
}

