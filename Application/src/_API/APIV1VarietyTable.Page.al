page 6014530 "NPR APIV1 Variety Table"
{

    APIGroup = 'variety';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'VarietyTable';
    DelayedInsert = true;
    EntityName = 'varietyTable';
    EntitySetName = 'varietyTables';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Variety Table";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'type', Locked = true;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(copyfrom; Rec."Copy from")
                {
                    Caption = 'copyfrom', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(isCopy; Rec."Is Copy")
                {
                    Caption = 'isCopy', Locked = true;
                }
                field(lockTable; Rec."Lock Table")
                {
                    Caption = 'lockTable', Locked = true;
                }
                field(pretagInVariantDescription; Rec."Pre tag In Variant Description")
                {
                    Caption = 'pretagInVariantDescription', Locked = true;
                }
                field(useDescriptionfield; Rec."Use Description field")
                {
                    Caption = 'useDescriptionfield', Locked = true;
                }
                field(useinVariantDescription; Rec."Use in Variant Description")
                {
                    Caption = 'useinVariantDescription', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
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
