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
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(dimensionId; Rec."Dimension Id")
                {
                    Caption = 'Dimension Id';
                }

                field(dimensionCode; Rec."Dimension Code")
                {
                    Caption = 'Dimension Code';
                }

                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }

                field(dimensionValueType; Rec."Dimension Value Type")
                {
                    Caption = 'Dimension Value Type';
                }

                field(totaling; Rec.Totaling)
                {
                    Caption = 'Totaling';
                }

                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }

                field(consolidationCode; Rec."Consolidation Code")
                {
                    Caption = 'Consolidation Code';
                }

                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation';
                }

                field(globalDimensionNo; Rec."Global Dimension No.")
                {
                    Caption = 'Global Dimension No.';
                }

                field(mapToICDimensionCode; Rec."Map-to IC Dimension Code")
                {
                    Caption = 'Map-to IC Dimension Code';
                }

                field(mapToICDimensionValueCode; Rec."Map-to IC Dimension Value Code")
                {
                    Caption = 'Map-to IC Dimension Value Code';
                }

                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
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
}