page 6014535 "NPR APIV1 - Variety Value"
{

    APIGroup = 'variety';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'aPIV1VarietyValue';
    DelayedInsert = true;
    EntityName = 'varietyValue';
    EntitySetName = 'varietyValues';
    Extensible = false;
    PageType = API;
    ODataKeyFields = SystemId;
    SourceTable = "NPR Variety Value";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'systemId', Locked = true;
                }
                field("table"; Rec.Table)
                {
                    Caption = 'table', Locked = true;
                }
                field(type; Rec.Type)
                {
                    Caption = 'type', Locked = true;
                }
                field(value; Rec.Value)
                {
                    Caption = 'value', Locked = true;
                }
                field(sortOrder; Rec."Sort Order")
                {
                    Caption = 'sortOrder', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
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
